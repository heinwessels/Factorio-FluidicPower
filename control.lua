local build_tools = require("scripts.fluidic-build-tools")
local poles = require("scripts.fluidic-handle-poles")
local overlay = require("scripts.overlay")
local fluidic_utils = require("scripts.fluidic-utils")
local pole_gui = require("scripts.pole-gui")

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

local function creation_event (event)        
    
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

local function removal_event (event, die)
    -- First need build tools to check connections
    -- before the removal event is triggered
    build_tools.on_entity_removed(event)

    poles.on_entity_removed(event, die)
end
local function die_event(event) removal_event(event, true) end    -- Ugly hack.

script.on_event(defines.events.on_player_mined_entity, removal_event)
script.on_event(defines.events.on_robot_mined_entity, removal_event)
script.on_event(defines.events.on_entity_died, die_event)
script.on_event(defines.events.script_raised_destroy, removal_event)

script.on_event(defines.events.on_gui_opened, function(event)
    if event.gui_type ~= defines.gui_type.entity then return end
    local pole = event.entity
    if not pole then return end
    local player = game.get_player(event.player_index)
    if not player then return end
    pole_gui.open_for_player(pole, player)
end)


local function ontick_event (event)
    build_tools.ontick(event)
    overlay.ontick(event)

    -- Don't update GUI every tick
    if game.tick % 10 ~= 0 then return end -- factor of 60
    for _, player in pairs(game.connected_players) do
        pole_gui.refresh_for_player(player)
    end
end
script.on_event(defines.events.on_tick, ontick_event)

script.on_init(function()
    -- Previous versions might not have this initiated.
    -- It's fine to reset them.
    global.neigbours_to_check = { }
    global.overlay_iterators = { }
    global.players = { }

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
    global.neigbours_to_check = global.neigbours_to_check or { }
    global.overlay_iterators = global.overlay_iterators or { }
    global.players = global.players or { }

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