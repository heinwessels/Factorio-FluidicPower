local fluidic_utils = require("scripts.fluidic-utils")
local overlay = {}

-- IN GLOBAL
--  Remember when we draw overlays
--  Each player will have an entry containing the entity unit number
--      global.overlay_iterators = { } 


function overlay.ontick (event)   

    -- Iterate for each player
    for _, player in pairs(game.connected_players) do
        local uid = player.index -- Unique key for player

        -- Check for the current selected entity
        if player.selected and string.match(player.selected.name, "fluidic") then        
            local entity = player.selected        
            -- The player currently has his mouse over a fluidic entity

             -- First get the fluidic entity if it's covered by an electric entity
             if string.sub(entity.name, -8, -1) == "electric" then
                -- At the moment power pole is selected, not fluid entity.
                -- Get the fluid entity
                local e = entity.surface.find_entity(
                    string.sub(entity.name, 1, -10),  -- Remove '-electric' keyword
                    entity.position
                )
                if not e then error(
                    [[There should be a fluidic fluid entity here. Bug report the developer please.
                    Original: <]]..entity.name..[[>.
                    Searched: <]]..string.sub(entity.name, 1, -10)..[[>]]
                ) end                
                entity = e  -- This should exist. If not, there's a problem.
            end
            
            local iterator = global.overlay_iterators[uid]
            if iterator and not iterator.base.valid then
                iterator = nil
                overlay.reset_rendering() 
            end -- Reset if something went wrong

            -- Now check if we are already handling this entity
            if not iterator or not iterator.base.valid or iterator.base.unit_number ~= entity.unit_number then
                -- It's a new entity! (and not a previously looked at entity)

                -- Were we already looking at this entity? We're lo
                if iterator then
                    if iterator.base.unit_number ~= entity.unit_number then
                        -- If moved to a new entity reset the rendering.
                        -- This means it will have to redraw for other players. But for them
                        -- the reset_rendering will not be called.
                        overlay.reset_rendering()
                    end
                end  

                -- Setup a new iterator
                iterator = {
                    base = entity,
                    white_list = {
                        {
                            this_node = entity,
                            prev_node = nil,

                            -- Need to add one here, because the first neighbour is already one deep
                            depth = settings.global["fluidic-electric-overlay-depth"].value + 1,
                        }
                    },
                    black_list = { },
                }

                -- Make sure the iterator is saved
                global.overlay_iterators[uid] = iterator
            else
                -- We're already handling the overlay for this target
            end
        else
            -- Not looking at anything important
            if global.overlay_iterators[uid] ~= nil then
                overlay.reset_rendering()
            end
        end

        -- Now iterate for this player
        local iterator = global.overlay_iterators[uid]        
        if iterator then
            if iterator.base.valid then
                -- Iterate!
                overlay.iterate_fluidbox_connections(player, iterator)
            else
                -- The base entity doesn't exist anymore for some reason
                overlay.reset_rendering()
            end
        end
    end
end

function overlay.iterate_fluidbox_connections(player, iterator)
    -- Takes another step in iterating the drawing of fluidbox
    -- connections. It takes the <iterator> object that contains
    -- {
    --      base = ..  -- reference to base entity
    --      white_list = {
    --          {
    --              this_node = reference to node to iterate on
    --              prev_node = reference to the node that called this node
    --              depth = the depth of this node
    --          },
    --      } -- list of references to entities that needs iteration with node that called them
    --      black_list = { .. 
    --          unit_number : { ... table of unit_numbers this connected to with unit_number as key ... },
    --          ...
    --      } -- list of unit numbers with the depth at which they were drawn
    -- }

    if not iterator.base or not iterator.base.valid then
        -- The base entity was deselected or destroyed.
        -- TODO Handle
    end

    if not next(iterator.white_list) then
        -- We've drawn everything we need
        -- (meaning there's nothing in the white_list)
        return
    end

    -- Get one node and handle it
    local this_iteration = table.remove(iterator.white_list, 1)
    local node = this_iteration.this_node
    local prev_node = this_iteration.prev_node
    local depth = this_iteration.depth
    
    if not node.valid then
        overlay.reset_rendering()
        return
    end

    -- Draw the connection if there is a previous node to draw to
    if prev_node and (prev_node.valid or false) then

        -- Has this connection been drawn since it's been put on the white list?
        local been_drawn_before = false
        if iterator.black_list[prev_node.unit_number] then
            if iterator.black_list[prev_node.unit_number][node.unit_number] then
                -- A connection has already been drawn from the prev_node to node
                been_drawn_before = true
            end
        end
        if iterator.black_list[node.unit_number] then
            if iterator.black_list[node.unit_number][prev_node.unit_number] then
                -- A connection has already been drawn from this node to prev_node
                been_drawn_before = true
            end
        end

        if not been_drawn_before then
            -- Okay draw it yo!
            overlay.draw_connection(player, node, prev_node)
        end

        -- But, remember we've drawn this connection.
        if not iterator.black_list[node.unit_number] then
            iterator.black_list[node.unit_number] = { }
        end
        iterator.black_list[node.unit_number][prev_node.unit_number] = depth
    end
    
    -- Determine any new nodes
    if depth > 0 then
        -- But only we're not already deep enough

        -- Keep track of new nodes added this iteration to 
        -- make sure we don't add the same one twice
        -- (there's double fluidboxes sometimes that can connect)
        local added_nodes = {}  -- table with entity unit_numbers as keys

        -- Actually look for new nodes
        for _, new_node in pairs(fluidic_utils.get_fluid_neighbours(node)) do
            local valid_new_node = true
            
            -- Have we already added this neighbour?
            if added_nodes[new_node.unit_number] then
                -- Yes.
                valid_new_node = false
            end
            
            -- Has this connection been drawn Before?
            if iterator.black_list[new_node.unit_number] then
                if iterator.black_list[new_node.unit_number][node.unit_number] then
                    -- A connection has already been drawn from the new node to this one
                    valid_new_node = false
                end
            end
            if iterator.black_list[node.unit_number] then
                if iterator.black_list[node.unit_number][new_node.unit_number] then
                    -- A connection has already been drawn from this node to new_node
                    valid_new_node = false
                end
            end
            
            -- Should not travel between source poles
            if string.sub(node.name, -2, -1)=='in' and string.sub(new_node.name, -2, -1)=='in' then
                valid_new_node = false
            end
            
            -- This node can be added to the white_list
            if valid_new_node then
                table.insert(iterator.white_list, {
                    this_node = new_node,
                    prev_node = node,
                    depth = depth - 1
                })

                -- Remember we added it this round
                added_nodes[new_node.unit_number] = true;
            end
        end
    end
end

function overlay.draw_connection(player, this_entity, that_entity)    
    -- First determine line colour
    local high_voltage = {    -- Or line that can carry high voltage at least
        colour = {r = 0,  g = 0.6, b = 0, a = 0},
        width = 5,
        gap_length = 0,
        dash_length = 0,
    }
    local low_voltage = {    -- Or line that cannot carry high voltage at least
        colour = {r = 0,  g = 0.6, b = 0, a = 0},
        width = 3,
        gap_length = 0.2,
        dash_length = 0.5,
    }
    local format = low_voltage
    if this_entity.name == "fluidic-big-electric-pole" and 
            that_entity.name == "fluidic-big-electric-pole" then
        format = high_voltage
    elseif (this_entity.name == "fluidic-big-electric-pole" and 
            that_entity.name == "fluidic-transformer") or
            (this_entity.name == "fluidic-transformer" and 
            that_entity.name == "fluidic-big-electric-pole")
            then
        format = high_voltage
    end

    if fluidic_utils.is_connection_fluids_mixed(this_entity, that_entity) then
        -- Draw red circle around compromised entity
        format.colour = {r = 1,  g = 0, b = 0, a = 0}
        for _,entity in pairs{this_entity, that_entity} do
            rendering.draw_circle{
                color = {r = 1,  g = 0, b = 0, a = 0},
                width = 5,
                radius = 0.5,
                target = entity.position,
                surface = entity.surface,
                players = {player},
                only_in_alt_mode = false
            }
        end
        overlay.create_alert_for_mixed_fluids(player, this_entity)
    end

    -- Draw orange circles over empty power poles
    for _, entity in pairs{this_entity, that_entity} do
        if overlay.is_pole_empty(entity) == true then
            rendering.draw_circle{
                color = {r = 1, g = 0.64, b = 0, a = 0},
                width = 3,
                radius = 0.25,
                target = entity.position,
                surface = entity.surface,
                players = {player},
                only_in_alt_mode = false
            }
        end
    end

    -- Draw the line between the entities
    rendering.draw_line{
        color = format.colour,
        width = format.width,
        gap_length = format.gap_length,
        dash_length = format.dash_length,
        from = this_entity.position,
        to = that_entity.position,
        surface = this_entity.surface,
        players = {player},
        only_in_alt_mode = false
    }
end

function overlay.create_alert_for_mixed_fluids(player, entity)
    local alerts = player.get_alerts{
        type = defines.alert_type.custom,
    }
    local too_close = false
    if alerts[player.surface.index] and alerts[player.surface.index][defines.alert_type.custom] then
        for _, alert in pairs(alerts[player.surface.index][defines.alert_type.custom]) do
            -- If this alert is too close we will assume that it's the same broken connection
            local range = 10
            if (entity.position.x > alert.position.x - range) and (entity.position.x < alert.position.x + range)
                and (entity.position.y > alert.position.y - range) and (entity.position.y < alert.position.y + range)
            then
                -- It's too close. Don't trigger.
                return
            end
        end
    end
    player.add_custom_alert(
        entity,
        {type="fluid", name = "fluidic-megajoules"},
        {"fluidic-text.fluidic-mixed-voltage-alert"},
        true
    )
end



function overlay.is_pole_empty(entity)
    -- Ignore anything that is not a pole
    if not (string.match(entity.name, "electric") or string.match(entity.name, "substation")) then
        return 
    end
    for this_index = 1, #entity.fluidbox do
        if not entity.fluidbox[this_index] then
            return true
        end
    end
    return false
end


function overlay.reset_rendering()    
    rendering.clear('FluidicPower')
    global.overlay_iterators = { }    -- Everybody redraw
end

return overlay