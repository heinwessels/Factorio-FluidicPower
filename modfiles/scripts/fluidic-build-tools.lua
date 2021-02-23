local script_data =
{
    current_overlay_target = nil
}

script.on_event(defines.events.on_tick, function (event)

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

