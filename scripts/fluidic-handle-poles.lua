local fluidic_utils = require("scripts.fluidic-utils")
local config = require("config")
local util = require("util")

local poles = {}

-------------------------
-- HANDLERS
-------------------------

local function disconnect_entity_and_neighbours(entity)
    -- Removes all copper wires from current entity,
    -- and all the entities it might have connected too
    -- We assume it's an electric pole

    -- Have we deleted this entity? Then do nothing.
    if not entity.valid then return end
    
    -- Don't do it unnecessarily. 
    local count = 0
    for _ in pairs(entity.neighbours.copper) do count = count + 1 end
    if count == 0 then return end

    -- Now disconnect the entity itself from any remaining poles
    entity.disconnect_neighbour()
end

function poles.on_entity_created(event)
    local entity
    if event.entity and event.entity.valid then
        entity = event.entity
    end
    if event.created_entity and event.created_entity.valid then
        entity = event.created_entity
    end
    if not entity then return end
    if not entity.valid then return end
    if string.sub(entity.name, 1, 7) ~= "fluidic" then return end
        
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

        -- This is the hidden fluid entity. Mark it as
        -- indestructable so it cannot be targetted by biters and destroyed,
        -- although we still handle that case with the `die` flag
        entity.destructible = false
    end

    -- Now create whatever is needed to assist this entity
    local fluid_name = config.entity_fluid_to_electric_lu[entity.name]
    if fluid_name then

        -- Place the electronic entity on the fluid entity
        -- But only if it doesn't exist already
        if not fluidic_utils.entity_exists_at(
            fluid_name, 
            entity.surface, 
            entity.position
        ) then
            local pole = entity.surface.create_entity{
                name = fluid_name,
                position = {x = entity.position.x, y = entity.position.y},
                direction = entity.direction,                
                force = entity.force,
                
                -- Building limitation has already been triggered. 
                -- No need to raise the event
                raise_built = false -- TODO SHOULD BE FALSE
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
    local electric_name = config.entity_electric_to_fluid_lu[entity.name]
    if electric_name then
        -- It could be an occation like this. Does the fluidy part exist?
        if not fluidic_utils.entity_exists_at(
            electric_name, 
            entity.surface, entity.position
        ) then
            -- Entity is not there.
            entity.surface.create_entity{
                name = electric_name,
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

function poles.on_entity_removed(event, die)
    -- This simply destroys the fluid entity undeneath the electric entity
    if event.entity and event.entity.valid then
        local entity = event.entity
        if string.sub(entity.name, 1, 7) ~= "fluidic" then return end

        local surface = entity.surface
        local fluid_name = config.entity_fluid_to_electric_lu[entity.name]
        local electric_name = config.entity_electric_to_fluid_lu[entity.name]
        if fluid_name then
            -- The removed/died entity is the fluidic component.
            -- This should ideally not happen, so it needs to be
            -- handled carefully if it's a death

            -- Destroy the fluidic component beneath
            local e = surface.find_entity(
                fluid_name, 
                entity.position
            )            
            if e then 
                -- Need to handle it correctly
                if not die then 
                    e.destroy{raise_destroy=false} 
                else
                    -- Sometime the killer is nil.
                    -- Handle it correctly
                    local killer = event.cause
                    if killer and killer.valid then
                        e.die(killer.force, killer)
                    else
                        e.die()
                    end
                end
            end

        elseif electric_name then
            -- The removed entity is the electric entity on top.
            -- When placing blueprint with wrong connection
            -- the electric entity will already be there, which
            -- means we need to add this hack to delete it.
            -- TODO Fix blueprinting
            -- TODO What?

            -- Destroy the electric component on top
            local e = surface.find_entity(
                electric_name,
                entity.position
            )
            if e then e.destroy{raise_destroy=false} end
        end
    end
end

return poles