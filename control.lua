local build_tools = require("scripts.fluidic-build-tools")
local poles = require("scripts.fluidic-handle-poles")
local overlay = require("scripts.overlay")
local fluidic_utils = require("scripts.fluidic-utils")

local function pickerdolly_handler(event)
    local top_entity = event.moved_entity
    local hidden_entity_name = 
        fluidic_utils.entity_electric_to_fluid_lu[top_entity.name]
    if hidden_entity_name then
        local hidden_entity = top_entity.surface.find_entity(
            hidden_entity_name,
            event.start_pos
        )
        if hidden_entity then
            hidden_entity.teleport(top_entity.position)
        else
            error("There should be a hidden entity here")
        end
    end
end

function creation_event (event)        
    
    -- First need build tools to check connections
    -- before the creation event is triggered
    build_tools.on_entity_created(event)

    poles.on_entity_created(event)
end

script.on_event(defines.events.on_built_entity, creation_event)
script.on_event(defines.events.on_robot_built_entity, creation_event)
script.on_event(defines.events.script_raised_built, creation_event)
script.on_event(defines.events.script_raised_revive, creation_event)
script.on_event(defines.events.on_robot_built_entity, creation_event)

function removal_event (event, die)
    -- First need build tools to check connections
    -- before the removal event is triggered
    build_tools.on_entity_removed(event)

    poles.on_entity_removed(event, die)
end
function die_event(event) removal_event(event, true) end    -- Ugly hack.

script.on_event(defines.events.on_player_mined_entity, removal_event)
script.on_event(defines.events.on_robot_mined_entity, removal_event)
script.on_event(defines.events.on_entity_died, die_event)
script.on_event(defines.events.script_raised_destroy, removal_event)

function ontick_event (event)
    build_tools.ontick(event)
    overlay.ontick(event)
end
script.on_event(defines.events.on_tick, ontick_event)

script.on_init(function()
    -- Previous versions might not have this initiated.
    -- It's fine to reset them.
    global.neigbours_to_check = { }
    global.overlay_iterators = { }

    if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), pickerdolly_handler)
    end
end)

script.on_load(function()
    -- Add support for picker dollies
    if remote.interfaces["PickerDollies"] 
        and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), pickerdolly_handler)
    end
end)

-- Hack this in here for now. TODO Move somewhere else
script.on_configuration_changed(function()

    -- Previous versions might not have this initiated.
    -- It's fine to reset them.
    global.neigbours_to_check = { }
    global.overlay_iterators = { }

    for index, force in pairs(game.forces) do
        local technologies = force.technologies
        local recipes = force.recipes        
        recipes["fluidic-energy-sensor"].enabled = technologies["circuit-network"].researched
    end
end)



-- Nice command ingame to see which entities are underneath the pointer
-- /c for _,e in pairs(game.player.surface.find_entities({game.player.selected.position, game.player.selected.position})) do game.print(e.name) end

-- Destroy specific entity
-- /c game.player.surface.find_entity("fluidic-medium-electric-pole-electric", game.player.selected.position).destroy()

-- TO USE DEBUGGER LOG
-- require('__debugadapter__/debugadapter.lua')
-- __DebugAdapter.print(expr,alsoLookIn)\