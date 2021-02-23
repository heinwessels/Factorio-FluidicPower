

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

    if black_list == nil then black_list = {} end

    if depth == 0 then return end   -- Recursion stop
    for _, neighbours_section in ipairs(entity.neighbours) do
        if next(neighbours_section) == nil then break end    -- Table is empty
        for _, neighbour in ipairs(neighbours_section) do
            
            -- TODO Verify neighbour (e.g. can't connect through 'in')

            -- Is this neighbour on the blacklist?
            local is_blacklisted = false
            -- for _, black in pairs(black_list) do
            --     if neighbour == black then
            --         is_blacklisted = true
            --     end
            -- end
            
            if is_blacklisted == false then
                -- This is a new neighbour
                draw_connection(entity, neighbour)

                -- Recursively draw neighbours' neighbours after blacklisting the neighbour itself
                black_list[#black_list + 1] = neighbour
                show_fluidic_entity_connections(neighbour, depth - 1, black_list)
            end 
        end 
    end
end

function draw_connection(this, that)
    rendering.draw_line{
        color = {b = 0, g = 1, a = 0},
        width = 3,
        from = this.position,
        to = that.position,
        surface = this.surface,
        players = players
    }   
end

function reset_rendering()
    -- TODO Make this specific to the lines I draw?
    rendering.clear()
end

