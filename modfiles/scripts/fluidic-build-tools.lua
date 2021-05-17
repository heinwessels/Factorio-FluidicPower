fluidic_utils = require("scripts.fluidic-utils")
util = require("util")

build_tools = {}

local script_data =
{   
    -- Here a list is kept of fluid connections to check for
    -- illegal building. It contains a list of {entity, neighbours, event}
    -- where we expect the entity to have been destroyed already.
    neigbours_to_check = { },
}

function build_tools.on_entity_created(event)    
    local entity
    if event.entity and event.entity.valid then
        entity = event.entity
    end
    if event.created_entity and event.created_entity.valid then
        entity = event.created_entity
    end
    if not entity then return end
    if entity.name == "entity-ghost" then return end
    
    -- Something has been built. Make sure there are no unwanted connections    
    for _, neighbour in pairs(fluidic_utils.get_fluid_neighbours(entity)) do
        if not is_valid_fluid_connection(entity, neighbour) then
            -- Invalid connection!
            -- User is trying to connect a normal fluid to
            -- a power fluid!
            
            -- Notify the player (or all the players actually)
            entity.surface.create_entity{
                name = "flying-text",
                type = "flying-text",
                text = {"fluidic-text.fluidic-cant-connect-to-romal-fluids"},
                position  = entity.position
            }
            
            if settings.global["fluidic-enable-build-limitations"].value then

                -- Keep local copy to return an item to the player
                local entity_copy = util.copy(entity)
                return_item_from_entity(event, entity_copy) -- The <entity> will be invalid by now

                -- Destroy the entity
                entity.destroy{
                    -- It's requried (I believe) to raise this event incase
                    -- the other entity is modded and needs the event.
                    raise_destroy=true
                }
            end

            -- Don't look at other neighbours, already destroyed this entity.
            return
        end                    
    end   
end

function build_tools.on_entity_removed(event)
    
    if event.entity and event.entity.valid then
        local entity = event.entity
        
        -- Something has been removed. We need to make sure it creates no
        -- new unwanted connections. We can't check it now though, since
        -- the entity that's being removed is still in the way. So we will
        -- see if it *could* interfere, and if it could, we will check it again
        -- in the next tick.

        -- If it's one of our poles we need to get the fluid component.
        -- Otherwise, just check the normal entity
        local entity_to_check = fluidic_utils.get_fluidic_entity_from_electric(entity)
        if not entity_to_check then entity_to_check = entity end
        
        -- Now check if it has fluidboxes
        if has_underground_fluidbox(entity_to_check) then
            -- This entity could have underground neighbours.

            local neighbours = fluidic_utils.get_fluid_neighbours(entity_to_check)
            if neighbours then
                -- And it has neighbours. We will check it next tick

                table.insert(
                    script_data.neigbours_to_check,
                    {
                        entity = entity_to_check,
                        neighbours = neighbours,
                        event = event
                    }
                )
            end
        end
    end    
end

function build_tools.ontick (event)
    -- This functions only occationally draws an overlay.
    -- NOTE: No on_tick fluid calculations are done!

    -- If there was a destroy event, make sure it didn't
    -- create any unwanted fluid connections
    check_fluid_connection_backlog()
end

function check_fluid_connection_backlog()
    -- During <on_entity_removed> we cannot check for 
    -- any new connections that might be wrong because
    -- the original entity is still in the way.

    for key, entry in pairs(script_data.neigbours_to_check) do

        -- If entry is not valid then it was removed
        if not entry.entity.valid then
            
            local neighbours = entry.neighbours

            -- Now make sure this didn't create any unwanted connections
            for _, neighbour in ipairs(neighbours) do
                
                -- Make sure this entity wasn't removed in the mean time
                if not neighbour.valid then break end

                -- Between this neighbour and his neighbours
                local his_neighbours = fluidic_utils.get_fluid_neighbours(neighbour)
                for _, his_neighbour in ipairs(his_neighbours) do

                    if not is_valid_fluid_connection(neighbour, his_neighbour) then
                        -- Invalid connection with the neighbour's neighbour!
                        -- It might connect a normal pipe to a fluidic pipe!

                        -- Decide which entity is wrong
                        local entity_to_destroy = his_neighbour
                        if string.match(his_neighbour.name, "fluidic") then entity_to_destroy = neighbour end

                        -- Notify the player. (Or all the players actually)
                        neighbour.surface.create_entity{
                            name = "flying-text",
                            type = "flying-text",
                            text = {"fluidic-text.fluidic-cant-connect-to-romal-fluids"},
                            position  = entity_to_destroy.position
                        }
                        
                        if settings.global["fluidic-enable-build-limitations"].value then
                            -- Destroy the non-fluidic entiry to avoid this connection.
                            -- And give the player the item back                        

                            -- Keep local copy to return an item to the player
                            local entity_copy = util.table.deepcopy(entity_to_destroy)
                            return_item_from_entity(entry.event, entity_copy) -- The <entity> will be invalid by now

                            entity_to_destroy.destroy{
                                -- We must allways raise an destroy event on other entities. 
                                --- It could be a modded entity and need the destroy event.
                                raise_destroy=true
                            }
                        end
                    end
                end
            end
        end

        -- Now delete the entry
        script_data.neigbours_to_check[key] = nil
    end
end

function return_item_from_entity(event, entity)
    -- Returns the required <item> back to the player.
    -- Either to his inventory or it's dropped on the floor
    -- with a deconstruction planner, depending on the <event>
    -- This function does not destroy the entity.
    
    -- Should we drop items on the floor?    
    local drop_item = false
    if event.robot then drop_item = true end

    if not drop_item then 
        -- It wasn't a robot action. Can we give it to the player?

        local player = 
            (event.player_index and game.get_player(event.player_index)) or nil
        if player then
            -- We know what player did the action. Try give it to him
            for _, product in pairs(entity.prototype.mineable_properties.products) do
                if not player.insert{name=product.name or product[1], count=product.amount or product[2]} then
                    -- Player inventory was full.
                    drop_item = true
                end
            end              
        else
            -- We don't know who the player was.
            drop_item = true
        end
    end

    if drop_item then
        -- We couldn't give the item back to the player. Drop it on the floor
        fluidic_utils.drop_items_with_decon(
            entity.surface,
            "player",
            entity.prototype.mineable_properties.products[1],
            entity.position
        )
    end
end

function has_underground_fluidbox(entity)
    -- Returns true if this entity has an underground 
    -- fluidbox connection that can connect to one
    -- of our poles.

    if not entity.prototype.fluidbox_prototypes then return false end
    for _, fluidbox in pairs(entity.prototype.fluidbox_prototypes) do
        for _, connection in pairs(fluidbox.pipe_connections) do
            if connection.max_underground_distance then
                -- It has an max underground distance field,
                -- meaning it can interact with fluidic power
                -- poles, or is an fluidic power pole.
                return true
            end
        end
    end
    
    -- Has fluid connections, but no underground ones
    return false
end

function is_valid_fluid_connection(this, that)
    -- Checks if the fluid connection between this entity 
    -- and that entity is invalid. Returns true if
    -- it's valid
    if string.match(this.name, "fluidic") and 
            string.match(that.name, "fluidic") then
        return true
    elseif not string.match(this.name, "fluidic") and 
            not string.match(that.name, "fluidic") then
        return true
    else
        return false
    end
end

return build_tools