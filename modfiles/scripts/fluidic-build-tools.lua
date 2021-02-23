

script.on_event(defines.events.on_tick, function (event)

    local player = game.players[1]

    if player.selected then        
        local entity = player.selected
        if string.match(entity.name, "fluidic") then
            -- The player currently has his mouse over a fluidic entity
            
            -- TODO Make depth a setting
            show_fluidic_entity_connections(entity, 5)
        else
            -- TODO Only reset if there is something to reset
            reset_rendering()
        end
    else
        reset_rendering()
    end 
end)


function show_fluidic_entity_connections(
    entity, depth, black_list
)   
    if depth == 0 then return end   -- Recursion stop
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
            -- TODO Verify that this works
            if black_list ~= nil then
                if neighbour == black_list then should_draw_connection = false end
            end
            
            -- TODO multiple fluidboxes could go to same entity

            if should_draw_connection then
                -- This is a new neighbour
                draw_connection(entity, neighbour)

                -- Recursively draw neighbours' neighbours after blacklisting the current entity
                show_fluidic_entity_connections(neighbour, depth - 1, entity)
            end 
        end 
    end
end

function draw_connection(this, that)
    rendering.draw_line{
        color = {r = 0,  g = 0.2, b = 0, a = 0},
        width = 3,
        from = this.position,
        to = that.position,
        surface = this.surface,
        players = players,
    }
    for _, point in ipairs{this, that} do
        rendering.draw_circle{
            color = {r = 0,  g = 0.5, b = 0, a = 0},
            radius = 0.25,
            width = 3,
            target = point.position,
            surface = this.surface,
            players = players,
        }
    end
end

function reset_rendering()
    -- TODO Make this specific to the lines I draw?
    rendering.clear()
end

