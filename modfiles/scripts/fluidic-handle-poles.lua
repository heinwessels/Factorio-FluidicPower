fluidic_utils = require("scripts.fluidic-utils")
util = require("util")

poles = {}

-- Which entity should be created on the following occations
local lu_on_created = {}
lu_on_created[
    "fluidic-small-electric-pole-in"
] = "fluidic-small-electric-pole-in-electric"
lu_on_created[
    "fluidic-small-electric-pole-out"
] = "fluidic-small-electric-pole-out-electric"
lu_on_created[
    "fluidic-medium-electric-pole-in"
] = "fluidic-medium-electric-pole-in-electric"
lu_on_created[
    "fluidic-medium-electric-pole-out"
] = "fluidic-medium-electric-pole-out-electric"
lu_on_created[
    "fluidic-substation-in"
] = "fluidic-substation-in-electric"
lu_on_created[
    "fluidic-substation-out"
] = "fluidic-substation-out-electric"
lu_on_created[
    "fluidic-big-electric-pole"
] = "fluidic-big-electric-pole-electric"

-- On entity destroyed connections lookup table
local lu_on_destroyed = {}
lu_on_destroyed[
    "fluidic-small-electric-pole-in-electric"
] = "fluidic-small-electric-pole-in"
lu_on_destroyed[
    "fluidic-small-electric-pole-out-electric"
] = "fluidic-small-electric-pole-out"
lu_on_destroyed[
    "fluidic-medium-electric-pole-in-electric"
] = "fluidic-medium-electric-pole-in"
lu_on_destroyed[
    "fluidic-medium-electric-pole-out-electric"
] = "fluidic-medium-electric-pole-out"
lu_on_destroyed[
    "fluidic-substation-in-electric"
] = "fluidic-substation-in"
lu_on_destroyed[
    "fluidic-substation-out-electric"
] = "fluidic-substation-out"
lu_on_destroyed[
    "fluidic-big-electric-pole-electric"
] = "fluidic-big-electric-pole"


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
        
    -- First check if a temporary "-place" entity was placed
    if string.match(entity.name, "-place") then
        -- Replace it with the correct entity
        local replaced = entity.surface.create_entity{
            name = string.sub(entity.name, 1, -7),
            position = {x = entity.position.x, y = entity.position.y},
            direction = entity.direction,                
            force = entity.force,
            raise_built = false
        }
        entity.destroy{raise_destroy=false}
        entity = replaced   -- Overwrite the value as if nothing happend
    end

    -- Now create whatever is needed to assist this entity
    if lu_on_created[entity.name] then

        -- Place the electronic entity on the fluid entity
        -- But only if it doesn't exist already
        if not fluidic_utils.entity_exists_at(
            lu_on_created[entity.name], 
            entity.surface, 
            entity.position
        ) then
            local pole = entity.surface.create_entity{
                name = lu_on_created[entity.name],
                position = {x = entity.position.x, y = entity.position.y},
                direction = entity.direction,                
                force = entity.force,
                
                raise_built = true -- Trigger the builder limitations.
            }

            -- Now remove the copper wires.
            -- <pole> should be a pole
            disconnect_entity_and_neighbours(pole)
        end
    end

    -- TODO Hacky sanity check because blueprints are still wonky
    -- When you blueprint a fluidic pole then it contains the electric
    -- part, and we want the fluidy part. So I add it here if it wasn't
    -- placed.
    -- TODO Why though?
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
                raise_built = true      -- This needs to be true for this hack.
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

    -- Have we deleted this entity? Then do nothing.
    if not entity.valid then return end

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
    -- This simply destroys the fluid entity undeneath the electric entity
    if event.entity and event.entity.valid then
        local surface = event.entity.surface
        if lu_on_destroyed[event.entity.name] then
            -- This entity was one of our special entities.

            -- -- Make sure the correct item is mined
            -- if fluidic_utils.table_has_attribute(event, "buffer") then
            --     event.buffer.clear()
            --     event.buffer.insert{name=lu_on_destroyed[event.entity.name]}
            -- end

            -- Destroy the fluidic component beneath
            local e = event.entity.surface.find_entity(
                lu_on_destroyed[event.entity.name], 
                event.entity.position
            )
            if e then e.destroy{raise_destroy=false} end

        elseif lu_on_created[event.entity.name] then
            -- When placing blueprint with wrong connection
            -- the electric entity will already be there, which
            -- means we need to add this hack to delete it.
            -- TODO Fix blueprinting

            -- Destroy the electric component on top
            local e = event.entity.surface.find_entity(
                lu_on_created[event.entity.name], 
                event.entity.position
            )
            if e then e.destroy{raise_destroy=false} end
        end
    end
end

return poles