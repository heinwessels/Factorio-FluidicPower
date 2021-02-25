fluidic_utils = require("scripts.fluidic-utils")

poles = {}

-- On entity created connections lookup table
local lu_on_created = {}
lu_on_created[
    "fluidic-small-pole-in"
] = "fluidic-small-pole-in-electric"
lu_on_created[
    "fluidic-small-pole-out"
] = "fluidic-small-pole-out-electric"
lu_on_created[
    "fluidic-medium-pole-in"
] = "fluidic-medium-pole-in-electric"
lu_on_created[
    "fluidic-medium-pole-out"
] = "fluidic-medium-pole-out-electric"
lu_on_created[
    "fluidic-substation-in"
] = "fluidic-substation-in-electric"
lu_on_created[
    "fluidic-substation-out"
] = "fluidic-substation-out-electric"

-- On entity destroyed connections lookup table
local lu_on_destroyed = {}
lu_on_destroyed[
    "fluidic-small-pole-in-electric"
] = "fluidic-small-pole-in"
lu_on_destroyed[
    "fluidic-small-pole-out-electric"
] = "fluidic-small-pole-out"
lu_on_destroyed[
    "fluidic-medium-pole-in-electric"
] = "fluidic-medium-pole-in"
lu_on_destroyed[
    "fluidic-medium-pole-out-electric"
] = "fluidic-medium-pole-out"
lu_on_destroyed[
    "fluidic-substation-in-electric"
] = "fluidic-substation-in"
lu_on_destroyed[
    "fluidic-substation-out-electric"
] = "fluidic-substation-out"



-------------------------
-- HANDLERS
-------------------------

function poles.on_entity_created(event)
    local entity
    if event.entity and event.entity.valid then
        entity = event.entity
    end
    if event.created_entity and event.created_entity.valid then
        entity = event.created_entity
    end
    if not entity then return end
    
    if lu_on_created[entity.name] then
        if not fluidic_utils.entity_exists_at(lu_on_created[entity.name], entity.surface, entity.position) 
        then
            entity.surface.create_entity{
                name = lu_on_created[entity.name],
                position = {x = entity.position.x, y = entity.position.y},
                direction = entity.direction,                
                force = entity.force,
                raise_built = false
            }        
        end
    end

    -- TODO Hacky sanity check because blueprints are still wonky
    -- When you blueprint a fluidic pole then it contains the electric
    -- part, and we want the fluidy part. So I add it here if it wasn't
    -- placed
    if lu_on_destroyed[entity.name] then
        -- It could be an occation like this. Does the fluidy part exist?
        if not fluidic_utils.entity_exists_at(
            lu_on_destroyed[entity.name], 
            entity.surface, entity.position
        ) then
            -- Entity is not there.
            entity.surface.create_entity{
                name = lu_on_destroyed[entity.name],
                position = {x = entity.position.x, y = entity.position.y},
                direction = entity.direction,                
                force = entity.force,
                raise_built = false
            }     
        end 
    end
end

function poles.on_entity_removed(event)
    if event.entity and event.entity.valid then
      local surface = event.entity.surface
      if lu_on_destroyed[event.entity.name] then
        local e = event.entity.surface.find_entity(lu_on_destroyed[event.entity.name], event.entity.position)
        if e then e.destroy{raise_destroy=false} end              
      end
    end
end

return poles