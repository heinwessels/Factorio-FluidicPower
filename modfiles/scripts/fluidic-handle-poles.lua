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


        -- Place the electronic entity on the fluid entity
        if not fluidic_utils.entity_exists_at(
            lu_on_created[entity.name], 
            entity.surface, 
            entity.position
        ) then
            -- But only if it doesn't exist already
            local pole = entity.surface.create_entity{
                name = lu_on_created[entity.name],
                position = {x = entity.position.x, y = entity.position.y},
                direction = entity.direction,                
                force = entity.force,
                raise_built = false
            }        

            -- Now remove the copper wires.
            -- <pole> should be a pole
            disconnect_entity_and_neighbours(pole)
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

        -- Also need to make sure no electric wires were placed
        disconnect_entity_and_neighbours(entity)
    end
end

function disconnect_entity_and_neighbours(entity)
    -- Removes all copper wires from current entity,
    -- and all the entities it might have connected too
    -- We assume it's an electric pole

    -- First disconnect his neighbours
    for _, neighbour in ipairs(entity.neighbours["copper"]) do
        if neighbour.name ~= "entity-ghost" then
            neighbour.disconnect_neighbour()
        end
    end

    -- Now disconnect the entity itself from any remaining poles
    entity.disconnect_neighbour()
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