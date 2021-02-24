small_pole = require("scripts.fluidic-small-pole")
medium_pole = require("scripts.fluidic-medium-pole")
substation = require("scripts.fluidic-substation")
build_tools = require("scripts.fluidic-build-tools")

function creation_event (event)
    small_pole.on_entity_created(event)
    medium_pole.on_entity_created(event)
    substation.on_entity_created(event)

    -- TODO Try to prevent "10xkiljoule being placed in big pole"
end

script.on_event(defines.events.on_built_entity, creation_event)
script.on_event(defines.events.on_robot_built_entity, creation_event)
script.on_event(defines.events.script_raised_built, creation_event)
script.on_event(defines.events.script_raised_revive, creation_event)

function removal_event (event)
    small_pole.on_entity_removed(event)
    medium_pole.on_entity_removed(event)    
    substation.on_entity_removed(event)    
end

script.on_event(defines.events.on_player_mined_entity, removal_event)
script.on_event(defines.events.on_robot_mined_entity, removal_event)
script.on_event(defines.events.on_entity_died, removal_event)
script.on_event(defines.events.script_raised_destroy, removal_event)
