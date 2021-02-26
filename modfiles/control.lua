build_tools = require("scripts.fluidic-build-tools")
poles = require("scripts.fluidic-handle-poles")

function creation_event (event)
    poles.on_entity_created(event)
    build_tools.on_entity_created(event)
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


function on_cursor_change (event)
    -- This is to fix the pipette tool picking up the non-electric entity
    build_tools.on_cursor_change(event)    
end
script.on_event(defines.events.on_player_cursor_stack_changed, on_cursor_change)


-- TODO Handle blueprints correctly. Need to remove electric poles
-- Currently when blueprinting it picks up both items


-- TODO Need an easy visualisation to see what power unit is in the current power pole. 
--  Maybe a little indicator similar to bottleneck. It shines through the bottom!