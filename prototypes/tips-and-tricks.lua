local poles = require("scripts.fluidic-handle-poles")
local overlay = require("scripts.overlay")
local config = require("config")
local util = require("util")

-- Build generic setup code for basic functionality during simulations
local function setup()
    return [[
        local config = load([=[]]..serpent.dump(config)..[[]=])()

        local surface = game.surfaces.nauvis
        local lib = { }

        function lib.pole_build_event(entity)
            if string.match(entity.name, "-place") then
                local replaced = entity.surface.create_entity{
                    name = string.sub(entity.name, 1, -7),
                    position = entity.position,
                    direction = entity.direction,                
                    force = entity.force,
                    raise_built = false
                }
                entity.destroy{raise_destroy=false}
                entity = replaced
            end
            
            local electric_variant = config.entity_fluid_to_electric_lu[entity.name]
            if electric_variant and not entity.surface.find_entity(electric_variant, entity.position) then
                local pole = entity.surface.create_entity{
                    name = electric_variant,
                    position = entity.position,
                    direction = entity.direction,                
                    force = entity.force,
                    raise_built = false
                }
                pole.disconnect_neighbour()
                return
            end

            local fluid_variant = config.entity_electric_to_fluid_lu[entity.name]
            if fluid_variant and not entity.surface.find_entity(fluid_variant, entity.position) then
                local pole = entity.surface.create_entity{
                    name = fluid_variant,
                    position = entity.position,
                    direction = entity.direction,                
                    force = entity.force,
                    raise_built = false
                }
                return
            end
        end

        script.on_event(defines.events.script_raised_built, function(event)
            lib.pole_build_event(event.entity)
        end)

        function lib.render_connection(this, that)
            function is_pole_empty(entity)
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
            function is_connection_fluids_mixed(this_entity, that_entity)
                if not this_entity.neighbours or 
                        not that_entity.neighbours then return false end
                for this_index = 1, #this_entity.fluidbox do
                    if this_entity.fluidbox[this_index] then
                        local this_fluid = this_entity.fluidbox[this_index]
                        for _, that_fluidbox in pairs(this_entity.fluidbox.get_connections(this_index)) do
                            if that_fluidbox.owner.unit_number == that_entity.unit_number then
                                -- We now this is a connection between this and that entity
                                for that_index = 1, #that_fluidbox do
                                    if that_fluidbox[that_index] ~= nil then
                                        -- Now we must make sure that that fluidbox is actually
                                        -- connected to this
                                        for _, backtrack_fluidbox in pairs(that_fluidbox.get_connections(that_index)) do
                                            if backtrack_fluidbox.owner.unit_number == this_entity.unit_number then
                                                local that_fluid = that_fluidbox[that_index]
                                                if this_fluid.name ~= that_fluid.name then
                                                    return {this_fluid, that_fluid}
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            local ctx = { }
            local this_config = config.poles[ config.entity_fluid_to_base_lu[ this.name ] ] or { }
            local that_config = config.poles[ config.entity_fluid_to_base_lu[ that.name ] ] or { }
            local is_mixed = is_connection_fluids_mixed(this, that) ~= nil

            local line_format
            if this_config.transmit_only and that_config.transmit_only then
                line_format = {
                    colour = {r = 0,  g = 0.6, b = 0, a = 0},
                    width = 5,
                    gap_length = 0,
                    dash_length = 0,
                }
            else
                line_format = {
                    colour = {r = 0,  g = 0.6, b = 0, a = 0},
                    width = 3,
                    gap_length = 0.2,
                    dash_length = 0.5,
                }
            end
            if is_mixed then 
                line_format.colour = {r = 1,  g = 0, b = 0, a = 0} 
            end
            
            for i, entity in pairs{this, that} do
                if is_mixed then
                    rendering.draw_circle{
                        color = {r = 1,  g = 0, b = 0, a = 0},
                        width = 5,
                        radius = 0.5,
                        target = entity.position,
                        surface = entity.surface,
                    }
                elseif ({is_pole_empty(this), is_pole_empty(that)})[i] then
                    rendering.draw_circle{
                        color = {r = 1, g = 0.64, b = 0, a = 0},
                        width = 3,
                        radius = 0.25,
                        target = entity.position,
                        surface = entity.surface,
                    }
                end
            end
    
            rendering.draw_line{
                color = line_format.colour,
                width = line_format.width,
                gap_length = line_format.gap_length,
                dash_length = line_format.dash_length,
                from = this.position,
                to = that.position,
                surface = this.surface
            }
        end

        function lib.update_all_poles(surface)
            for _, entity in pairs(surface.find_entities_filtered{radius=50}) do
                lib.pole_build_event(entity)
            end
        end

        function lib.render_all_connections_from(entity)
            local fluid_variant = config.entity_electric_to_fluid_lu[entity.name]
            if fluid_variant then
                entity = surface.find_entity(fluid_variant, entity.position)
                if not entity then error("could not find: "..fluid_variant) end
            end

            function get_fluid_neighbours(entity)    
                local neighbours = {}
                local neighbours_lu = {}
                if #entity.fluidbox == 0 then return neighbours end
                if not entity.neighbours then return neighbours end

                for _, neighbours_section in pairs(entity.neighbours) do
                    if next(neighbours_section) == nil then break end
                    for _, neighbour in ipairs(neighbours_section) do            
                        if not neighbours_lu[neighbour.unit_number] then
                            table.insert(neighbours, neighbour)
                            neighbours_lu[neighbour.unit_number]=true
                        end
                    end 
                end
                return neighbours
            end

            local white_list = { entity }
            local black_list = { }
            local function to_key(a, b) return math.min(a.unit_number, b.unit_number).."."..math.max(a.unit_number, b.unit_number) end
            
            local length = #white_list
            while length > 0 do
                local entity = white_list[#white_list]
                local neighbours = get_fluid_neighbours(entity)
                local neighbours_to_iterate = { }
                for _, neighbour in pairs(neighbours) do
                    if not black_list[to_key(entity, neighbour)] then
                        lib.render_connection(
                            entity, neighbour, 
                            {mixed = true})
                        black_list[to_key(entity, neighbour)] = true
                        table.insert(neighbours_to_iterate, neighbour)
                    end
                end

                table.remove(white_list, length)
                length = length - 1

                for _, neighbour in pairs(neighbours_to_iterate) do
                    table.insert(white_list, neighbour)
                    length = length + 1
                end
            end
        end

    ]]
end

do
    local tip = data.raw["tips-and-tricks-item"]["electric-pole-connections"]
    tip.trigger = {
        type = "sequence",
        triggers = {
            {
                type = "build-entity",
                entity = "fluidic-small-electric-pole-in-place",
                count = 15
            },
            {
                type = "build-entity",
                entity = "fluidic-small-electric-pole-out-place",
                count = 15
            }
        }
    }
    tip.simulation.init = [[
        ]]..setup()..[[

        local player = game.create_test_player{name = "Elvis"}
        player.character.teleport{0, 1}
        game.camera_player = player
        game.camera_zoom = 1.5
        game.camera_player_cursor_position = player.position

        surface.create_entities_from_blueprint_string{
            string = "0eNqVk91ugzAMhd/F10lVKD8drzJNVQoushQclIRpVcW7L4EJdS3tugsu7OR85yQxFzjqAXtL7KG6ANWGHVTvF3DUstKx5889QgXksQMBrLpYOY+qk8gtMcIogLjBL6iSUfwptapR9kqTjh8CkD15wtl7Ks4HHroj2gBdpMQn4rAkewpgAb1xQWU4egWSzDa5gHNQbPKJP+8+OPSeuHVx23X+SEBbBzvV4uQTgoaO8oON9Xa7FdCZJgqUlxqV8zDGI94kTJeEMZj0RrbWDNysRNz9itiQxXpeLla4u5e5D7HpCjZbf8Y7aPEfaL5AT3qghmrpOqW1RB1UNpS90SiJl8Zjv3CYtVsuXnIwg39ikaTPPcqbMb0H7H8AeQSEyZ2Gu7r6jQR8onXzPe2TrHxLyyIPX1KO4ze4myHA",
            position = {-5, -1},
            force = "player"
        }
        lib.update_all_poles(surface)

        local one = surface.find_entities_filtered{name="fluidic-small-electric-pole-in"}[1]
        local two = surface.find_entities_filtered{name="fluidic-small-electric-pole-out"}[1]
        
        local three_position = {x=6.5, y=-0.5}
        local three
        local state = "start"
        local counter
        player.cursor_ghost = "small-electric-pole"
        local drawn = false
        script.on_nth_tick(1, function() 
            if player.selected and not drawn then lib.render_all_connections_from(player.selected); drawn = true
            elseif not player.selected and drawn then rendering.clear(); drawn = false end

            if state == "start" then
                if game.move_cursor({position = three_position, speed = 0.1}) then
                    counter = 20
                    state = "wait-before-build"                    
                end
            elseif state == "wait-before-build" then
                counter = counter - 1
                if counter <= 0 then
                    surface.create_entity{name="fluidic-small-electric-pole-out-place", position = three_position, force="player", raise_built=true}
                    three = surface.find_entity("fluidic-small-electric-pole-out", three_position)
                    player.clear_cursor()
                    state = "post-build-return"
                end
            elseif state == "post-build-return" then
                if game.move_cursor({position = player.position, speed = 0.1}) then
                    state = "go-show-overlay"
                end
            elseif state == "go-show-overlay" then
                if game.move_cursor({position = three_position, speed = 0.1}) then
                    counter = 90
                    state = "wait-overlay"
                end
            elseif state == "wait-overlay" then
                counter = counter - 1
                if counter <= 0 then
                    state = "end"
                end
            elseif state == "end" then
                if game.move_cursor({position = player.position, speed = 0.1}) then
                    counter = 90
                    state = "wait-end"
                end
            elseif state == "wait-end" then
                counter = counter - 1
                if counter <= 0 then
                    rendering.clear()
                    state = "go-show-overlay"
                end
            end            
        end)
    ]]
end

do
    local tip = util.table.deepcopy(data.raw["tips-and-tricks-item"]["electric-pole-connections"])
    tip.name = "fluidic-electric-overlay"
    tip.tag = "[item=small-electric-pole]"
    tip.trigger = {
        type = "sequence",
        triggers = {
            {
                type = "build-entity",
                entity = "fluidic-small-electric-pole-in-place",
                count = 15
            },
            {
                type = "build-entity",
                entity = "fluidic-small-electric-pole-out-place",
                count = 15
            }
        }
    }
    tip.simulation.init_update_count = 600 -- To get the left poles to fill up, otherwise it doesn't show red
    tip.simulation.init = [[
        ]]..setup()..[[
        local player = game.create_test_player{name = "Alden Winters"}
        player.character.teleport{0, 1}
        game.camera_player = player
        game.camera_player_cursor_position = player.position
        game.camera_alt_info = true

        surface.create_entities_from_blueprint_string{
            string = "0eNqtlNtOwzAMht/F1wlqyrZufRWEULZ6lSGHKkkR09R3x+lENbGyAdpFpTixv992Uh9ha3rsArkE9RFo512E+ukIkVqnTd5Lhw6hBkpoQYDTNlsxobYy9WFLDmEQQK7BD6jV8CwAXaJEeAKNxuHF9XaLgR0mREcdyuRlG3zvGkZ3PnKYd1mUUbJUD0sBB47hxTCIC1Y5scjtyfGRzNCrqIJRYvJ/iZgSuTZmx/PSMgPDjgV1i2PWXD7vaC4520VRCLC+yQE6SYM6JpjL8fGHll3LcTNf7uI/rVuN9TYUcHdyWMyQlxN5b3pqaCctNtRbiYbDAtudNyh9n6adGVH1+CVazRewuovM+oZKdaESrTbmbyLljbtY30GkuKGx+V27yF29lK92lcW8iirue/k/6qgLnRS0i3sfLJ/PENWJp769XwG8pu4cpAr5RsbnX8Jiq199b3j6zCVR3vUJnmrliTcOx/pslgp4xxDHkHKtFtWmrFZL/lQ1DJ8SU9DD",
            position = {-5, -2},
            force = "player"
        }
        lib.update_all_poles(surface)
        
        local left = surface.find_entity("fluidic-medium-electric-pole-out", {-7.5, -0.5})
        local smol = surface.find_entities_filtered{name="fluidic-small-electric-pole-out"}[1]

        local state = "start"
        local counter
        local drawn = false
        script.on_nth_tick(1, function() 
            if player.selected and not drawn then lib.render_all_connections_from(player.selected); drawn = true
            elseif not player.selected and drawn then rendering.clear(); drawn = false end

            if state == "start" then
                if game.move_cursor({position = left.position, speed = 0.1}) then                    
                    counter = 60
                    state = "wait-transformer"                    
                end
            elseif state == "wait-transformer" then
                counter = counter - 1
                if counter <= 0 then
                    state = "middle"
                end
            elseif state == "middle" then
                if game.move_cursor({position = player.position, speed = 0.1}) then
                    counter = 60
                    state = "middle-wait"
                end
            elseif state == "middle-wait" then
                counter = counter - 1
                if counter <= 0 then
                    state = "smol"
                end
            elseif state == "smol" then
                if game.move_cursor({position = smol.position, speed = 0.1}) then                    
                    counter = 60
                    state = "wait-smol"                    
                end
            elseif state == "wait-smol" then
                counter = counter - 1
                if counter <= 0 then
                    state = "return"
                end
            elseif state == "return" then
                if game.move_cursor({position = player.position, speed = 0.1}) then
                    counter = 60
                    state = "end-wait"
                end
            elseif state == "end-wait" then
                counter = counter - 1
                if counter <= 0 then
                    state = "start"
                end
            end       
        end)        

    ]]
    data:extend{ tip }
end
        
do
    local tip = util.table.deepcopy(data.raw["tips-and-tricks-item"]["electric-pole-connections"])
    tip.name = "fluidic-transformers"
    tip.tag = "[item=fluidic-transformer]"
    tip.trigger = {
        type = "sequence",
        triggers = {
            {
                type = "build-entity",
                entity = "fluidic-big-electric-pole-place",
                count = 5
            },
            {
                type = "build-entity",
                entity = "fluidic-transformer",
                count = 1
            },
        }
    }
    tip.simulation.init_update_count = 600 -- To get the transformers filled up
    tip.simulation.init = [[
        ]]..setup()..[[
        local player = game.create_test_player{name = "Elvis"}
        player.character.teleport{0, 1}
        game.camera_player = player
        game.camera_player_cursor_position = player.position
        game.camera_alt_info = true
        game.camera_zoom = 1.25

        surface.create_entities_from_blueprint_string{
            string = "0eNqtmOFyoyAQx9+Fz9IR1Kh5lZtOxugmx52Cg9hpp5N3vyUmqWkgpuE+dDpI/C277H8X+STbdoReC2nI+pOIWsmBrH99kkHsZdXaZ+ajB7ImwkBHIiKrzo4GA1VHzai3QgI5RETIBt7Jmh2ixXfhvdcwDNToSg690oZuoTUzCD+8RgSkEUbAtJrj4GMjx24LGq1cWELuhMQpWv+GwaCNXg34mpLWul1P8pJF5IOsafGSHS1Mv98MYIyQ+8H+TkOn3mAz4lxrQEOzsQvGKaNHOFiPvtnnN760qmpw5o79HK2fwyH70fp7w02WYnSHn6J/DmQagMzcyCwAyd3IVQAycSPzC3ILFaa1A8FPiHhKjWnPMX17gIZ2qhlboIlNRwe+uFnxiMmr91rh/8U1s6PFUzqo0XjyobzN817gOzdkyrITmvnTfC5diwBdo71qD0dBoff4pEJJ23EcxxHBENgXKkNbqFBdrjiw+LJGuzRqFJ1i4FpkerXIRmiop/mVi8weJ5c+MHeB+RXYgStmOBcgWQLkC4B0CbBaAGRLgGwB8KW4XTuKRtR0K/YUWgycxkGvMPfPI9dWHuFOZbA8CJ3dIRc35GOZ2CnduYpvcUJFWOFr0c/f62Bf2YxiMf0rWvVHodYHlwRZeWOzg0aM3TeHUMR3nGLx/e3gsaez+nPTU+85e5iULZBmXe7s6m7UsqrhjoM+WEBr8xR4/iWiHVYnKuQA2jibMJ+RFssDz0JKO59Xdm+j5wENz9OVef480rdpxY8jnD5S2Xn5Mx3T9MguXEI+Cdhq2WraL+Qk/h8Vr3DFKWHPhz53hz7hzyNXHmTyWCUT8l4Yzo2p8BgJOG+WHmTAedO3ygD5MU8JTwL0Z6unk1kEMD1lMykDmJ7jexoHMD31LA0QFfN9DAWoinmUmgZ0NuaRahqgIuaRURogI+bRURqgI+7RURqgI+7RUVo8fmFwPsjw5IkLg13VDhCR6fF0dXG2q5WkStujU43nCIN93PGFNbtHeXU6Uj5+88DnbszPPA98eGYBguaewpMFCJp7Ck/2hKDT6w2+Oqu8TtcA9tLgci0WkTfcyyl0BUvzkuerDP9Yfjj8AzIaYq4=",
            position = {-3, 3},
            force = "player"
        }
        lib.update_all_poles(surface)

        local transformer = surface.find_entities_filtered{name="fluidic-transformer"}[1]

        local state = "start"
        local counter
        local drawn = false
        script.on_nth_tick(1, function() 
            if player.selected and not drawn then lib.render_all_connections_from(player.selected); drawn = true
            elseif not player.selected and drawn then rendering.clear(); drawn = false end

            if state == "start" then
                if game.move_cursor({position = transformer.position, speed = 0.1}) then                    
                    counter = 60
                    state = "wait"                    
                end
            elseif state == "wait" then
                counter = counter - 1
                if counter <= 0 then
                    state = "return"
                end
            elseif state == "return" then
                if game.move_cursor({position = player.position, speed = 0.1}) then
                    counter = 60
                    state = "end-wait"
                end
            elseif state == "end-wait" then
                counter = counter - 1
                if counter <= 0 then
                    state = "start"
                end
            end            
        end)
    ]]
    data:extend{ tip }
end


do
    local tip = data.raw["tips-and-tricks-item"]["low-power"]
    tip.simulation.init_update_count = 600 -- To get the poles filled up
    tip.simulation.init = [[
        for x = -5.5, -3.5, 1 do
          for y = 0.5, 2.5, 1 do
            game.surfaces[1].create_entity{name = "iron-ore", amount = 500, position = {x, y}}
          end
        end
        game.surfaces[1].create_entities_from_blueprint_string
        {
          string = "0eNqVlt1ygyAQhd+Fa+kE1Jj6Kp1OhuimYYrgwNppJuO7F5PG2AYTvPCCv28Pyx7wRHaqg9ZKjaQ8EVkZ7Uj5diJOfmihhj48tkBKIhEakhAtmqHljBKWtkKDIn1CpK7hm5SsT56uBAUVWlnRRmqpP2htpZoyeP+eENAoUcJFyrlx3Oqu2YH1QYIiEtIa59cYPUT2HFq85Ak5+vkveT/o+ofh94r2ndWiggCLP2alIwut0K41FukOFN6T2C9o5UEJqaX1oc+jPIDNorHpEmwejeVLsOtobL4EW0RjsyXYzYhVRtS+5w5XzMCSsa512yEJsF9HttR7X+V4pNUBXEDy5o/k6+ytA0TvDTfMstCYL9h2fkwhWKi3g5/8ENoOQsXIVk+8Nm+VLCZz7GbAvepk7fGuEUrRMVprFFCpx45AxGsJpGFDMT5JoQOLoQOi6QTyR3YWQqZRsk2Hj3SvnujOYnSzJ5B8Upv+1A7C34w1nQdeeTwqD/E+pdmiuoh36nj8ceBNPDidgEOomzX3wuGDnI4nnf+XuA49Jqt4iWwOHNo7Z8vBWUwZ8JvDhHPQ7NRwQTSiOkgNlM8X2UW2Z8vLJWiNpg5l9UmGh/v81peTn4qEfIF1l/1tWFa88mKd+48Vff8DGgHMMw==",
          position = {3,0}
        }
        ]]..setup()..[[
        lib.update_all_poles(surface)
      ]]
end