build_tools = {}

local script_data =
{
    current_overlay_target = nil
}


function build_tools.on_entity_created(event)

    if settings.global["fluidic-electric-overlay-depth"].value then
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
        if not entity.neighbours then return end
        for _, neighbour in ipairs(get_fluid_neighbours(entity)) do
            if is_isvalid_fluid_connection(entity, neighbour) then
                -- Invalid connection!
                -- User is trying to connect a normal fluid to
                -- a power fluid!
                
                -- Notify the player
                game.players[1].create_local_flying_text{
                    text = "Can't connect Fluidic Power with normal fluids",
                    position  = entity.position
                }
                
                -- Prevent player from placing this entity
                -- TODO Give the player the item back!
                entity.destroy()
                
                -- Don't look at other neighbours, already destroyed this entity.
                return
            end                    
        end
    end
end

function build_tools.on_entity_removed(event)
    if settings.global["fluidic-electric-overlay-depth"].value then
        if event.entity and event.entity.valid then
            local entity = event.entity
            -- Something has been removed. Make sure there are no unwanted connections
                                    
            -- Remember entity's neighbours and then destroy him as user wants
            local neighbours = get_fluid_neighbours(entity)
            entity.destroy()
            
            -- Now make sure this didn't create any unwanted connections
            for _, neighbour in ipairs(neighbours) do

                local his_neighbours = get_fluid_neighbours(neighbour)
                for _, his_neighbour in ipairs(his_neighbours) do

                    if is_isvalid_fluid_connection(neighbour, his_neighbour) then
                        -- Invalid connection with the neighbour's neighbour!
                        -- It might connect a normal pipe to a fluidic pipe!
                                                
                        -- Notify the player
                        game.players[1].create_local_flying_text{
                            text = "Can't connect Fluidic Power with normal fluids",
                            position  = neighbour.position
                        }
                        
                        -- Destroy this neighbour and go to the next neighbour
                        -- TODO Give the player the item back!
                        neighbour.destroy()
                        break                        
                    end
                end
            end
        end
    end
end

function is_isvalid_fluid_connection(this, that)
    -- Checks if the fluid connection between this entity 
    -- and that entity is invalid
    if string.match(this.name, "fluidic") and 
            not string.match(that.name, "fluidic") then
        return true
    elseif not string.match(this.name, "fluidic") and 
            string.match(that.name, "fluidic") then
        return true
    else
        return false
    end
end

script.on_event(defines.events.on_tick, function (event)
    -- This functions only occationally draws an overlay.
    -- No on_tick fluid calculations are done.

    local player = game.players[1]

    if player.selected and string.match(player.selected.name, "fluidic") then        
        local entity = player.selected        
        -- The player currently has his mouse over a fluidic entity
        
        if entity ~= script_data.current_overlay_target then
            -- It's a new target!            
            reset_rendering()   -- Make sure we don't have any left-over overlays
            
            script_data.current_overlay_target = entity
            show_fluidic_entity_connections(entity, settings.global["fluidic-electric-overlay-depth"].value)
        
        else
            -- We've already drawn the overlay for this target. Do nothing but wait.
        end
    else
        -- Not looking at anything important
        if script_data.current_overlay_target ~= nil then            
            reset_rendering()
            script_data.current_overlay_target = nil
        end
    end 
end)


function show_fluidic_entity_connections(
    entity, depth, black_list
)   
    if depth == 0 then return end   -- Recursion stop
    if black_list == nil then black_list = {} end
    for _, neighbours_section in ipairs(entity.neighbours) do
        if next(neighbours_section) == nil then break end    -- Table is empty
        for _, neighbour in ipairs(neighbours_section) do
            
            local should_draw_connection = true

            -- If both of these are <in> entities then this connection
            -- isn't valid. Check if it's an assembling machine.
            if entity.type == 'assembling-machine' and neighbour.type == 'assembling-machine' then
                should_draw_connection = false
            end

            -- Are we coming from this neighbour?
            if black_list ~= nil then
                -- if neighbour == black_list then should_draw_connection = false end
                if black_list[neighbour.unit_number] ~= nil then
                    -- TODO This elimination is too harsh, get better solution
                    -- Currently it doesn't draw nice diamonds.
                    should_draw_connection = false
                end
            end            

            if should_draw_connection then
                -- This is a new neighbour
                -- TODO draw from the fluidbox, not the entity
                draw_connection(entity, entity.position, neighbour.position)

                -- Recursively draw neighbours' neighbours after blacklisting the current entity
                black_list[entity.unit_number] = depth
                show_fluidic_entity_connections(neighbour, depth - 1, black_list)
            end 
        end 
    end
end

function draw_connection(entity, here, there)
    rendering.draw_line{
        color = {r = 0,  g = 0.6, b = 0, a = 0},
        width = 3,
        from = here,
        to = there,
        surface = entity.surface,
        players = players,
    }
    for _, point in ipairs{this, that} do
        rendering.draw_circle{
            color = {r = 0,  g = 0.5, b = 0, a = 0},
            radius = 0.25,
            width = 3,
            target = point,
            surface = entity.surface,
            players = players,
        }
    end
end

function reset_rendering()
    -- TODO Make this specific to the lines I draw?
    rendering.clear()
end

function get_fluid_neighbours(entity)
    -- Returns all fluid neighbours of this entity    
    local neighbours = {}

    -- Does this entity even have a fluidbox?
    if entity.fluidbox == nil then return neighbours end

    -- It does. Look at it's neighbours
    for _, neighbours_section in ipairs(entity.neighbours) do
        if next(neighbours_section) == nil then break end    -- Table is empty
        for _, neighbour in ipairs(neighbours_section) do
            
            table.insert(neighbours, neighbour)

        end 
    end
    return neighbours
end

function contains_key(this, wanted_key)
    for key, _ in pairs(this) do
        if key == wanted_key then return true end
    end
    return false
end

return build_tools