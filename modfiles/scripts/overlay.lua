fluidic_utils = require("scripts.fluidic-utils")
overlay = {}

local script_data =
{   
    -- Remember when we draw overlays
    -- Each player will have an entry containing the entity unit number
    overlay_iterators = { },
}

function overlay.ontick (event)
    
    -- Iterate for each player
    for _, player in pairs(game.players) do
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
            
            -- Now check if we are already handling this entity
            if not script_data.overlay_iterators[uid] or
                script_data.overlay_iterators[uid].base.unit_number ~= entity.unit_number
            then
                -- It's a new entity! (and not a previously looked at entity)

                -- Were we already looking at this entity? We're lo
                if script_data.overlay_iterators[uid] then
                    if script_data.overlay_iterators[uid].base.unit_number ~= entity.unit_number then
                        -- If moved to a new entity reset the rendering.
                        -- This means it will have to redraw for other players. But for them
                        -- the reset_rendering will not be called.
                        overlay.reset_rendering()
                    end
                end  

                -- Setup a new iterator
                script_data.overlay_iterators[uid] = {
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
            else
                -- We're already handling the overlay for this target
            end
        else
            -- Not looking at anything important
            if script_data.overlay_iterators[uid] ~= nil then
                overlay.reset_rendering()
            end
        end

        -- Now iterate for this player
        if script_data.overlay_iterators[uid] then
            if script_data.overlay_iterators[uid].base.valid then
                -- Iterate!
                overlay.iterate_fluidbox_connections(player, script_data.overlay_iterators[uid])
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
    --          unit_number : depth,
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

    -- Draw the connection if there is a previous node to draw to
    if prev_node and (prev_node.valid or false) then
        overlay.draw_connection(player, node, node.position, prev_node.position)
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

            -- Is this node on the blacklist?
            if iterator.black_list[new_node.unit_number] then
                -- This neighbour is on the blacklist, but does it have sufficient depth?
                if iterator.black_list[new_node.unit_number] >= depth then
                    -- Yes. Shouldn't draw to it again.
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
    
    -- Add this node to the blacklist
    iterator.black_list[node.unit_number] = depth

end

function overlay.draw_connection(player, entity, here, there)
    rendering.draw_line{
        color = {r = 0,  g = 0.6, b = 0, a = 0},
        width = 3,
        from = here,
        to = there,
        surface = entity.surface,
        players = {player},
        only_in_alt_mode = false
    }
    for _, point in ipairs{here, there} do
        rendering.draw_circle{
            color = {r = 0,  g = 0.5, b = 0, a = 0},
            radius = 0.25,
            width = 3,
            target = point,
            surface = entity.surface,
            players = {player},
            only_in_alt_mode = false
        }
    end
end

function overlay.reset_rendering()    
    rendering.clear('FluidicPower')
    script_data.overlay_iterators = { }    -- Everybody redraw
end

return overlay