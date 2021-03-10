build_tools = require("scripts.fluidic-build-tools")
poles = require("scripts.fluidic-handle-poles")

function creation_event (event)        
    
    build_tools.on_entity_created(event)

    -- First need build tools to make sure
    -- the placer we placed is valid.
    poles.on_entity_created(event)
end

script.on_event(defines.events.on_built_entity, creation_event)
script.on_event(defines.events.on_robot_built_entity, creation_event)
script.on_event(defines.events.script_raised_built, creation_event)
script.on_event(defines.events.script_raised_revive, creation_event)
script.on_event(defines.events.on_robot_built_entity, creation_event)

function removal_event (event)
    poles.on_entity_removed(event)
    build_tools.on_entity_removed(event)
end

script.on_event(defines.events.on_player_mined_entity, removal_event)
script.on_event(defines.events.on_robot_mined_entity, removal_event)
script.on_event(defines.events.on_entity_died, removal_event)
script.on_event(defines.events.script_raised_destroy, removal_event)

function ontick_event (event)
    build_tools.ontick(event)
end

script.on_event(defines.events.on_tick, ontick_event)


-- Nice command ingame to see which entities are underneath the pointer
-- /c for _,e in pairs(game.player.surface.find_entities({game.player.selected.position, game.player.selected.position})) do game.print(e.name) end

-- Destroy specific entity
-- /c game.player.surface.find_entity("fluidic-medium-electric-pole-electric", game.player.selected.position).destroy()