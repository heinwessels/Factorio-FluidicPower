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
            local ctx = { }
            local this_config = config.poles[ config.entity_fluid_to_base_lu[ this.name ] ] or { }
            local that_config = config.poles[ config.entity_fluid_to_base_lu[ that.name ] ] or { }

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
            if ctx.mixed then 
                line_format.colour = {r = 1,  g = 0, b = 0, a = 0} 
            end
            
            for i, entity in pairs{this, that} do
                if ctx.mixed then
                    rendering.draw_circle{
                        color = {r = 1,  g = 0, b = 0, a = 0},
                        width = 5,
                        radius = 0.5,
                        target = entity.position,
                        surface = entity.surface,
                    }
                elseif ({ctx.this_empty, ctx.that_empty})[i] then
                    rendering.draw_circle{
                        color = {r = 1, g = 0, b = 0, a = 0},
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

        function lib.render_all_connections()
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
            
            local poles_to_find = { }
            for pole_name, _ in pairs(config.entity_fluid_to_electric_lu) do 
                table.insert(poles_to_find, pole_name)
            end
            local white_list = surface.find_entities_filtered{name = poles_to_find}
            local black_list = { }
            local function to_key(a, b) return math.min(a.unit_number, b.unit_number).."."..math.max(a.unit_number, b.unit_number) end
            
            local length = #white_list
            while length > 0 do
                local entity = white_list[#white_list]
                local neighbours = get_fluid_neighbours(entity)
                for _, neighbour in pairs(neighbours) do
                    if not black_list[to_key(entity, neighbour)] then
                        lib.render_connection(entity, neighbour)
                        black_list[to_key(entity, neighbour)] = true
                    end
                end

                ::continue::
                table.remove(white_list, length)
                length = length - 1
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
                type = "time-elapsed",
                ticks = 4 * 60 * 60 * 60 -- 4 hours
            },
            {
                type = "build-entity",
                entity = "fluidic-small-electric-pole-in-place",
                match_type_only = true,
                count = 15
            },
            {
                type = "build-entity",
                entity = "fluidic-small-electric-pole-out-place",
                match_type_only = true,
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
            if player.selected and not drawn then lib.render_all_connections(); drawn = true
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
    tip.name = "electric-overlay"
    tip.tag = "[item=small-electric-pole]"
    tip.simulation.init = [[
        ]]..setup()..[[
    ]]
    data:extend{ tip }
end
        
do
    local tip = util.table.deepcopy(data.raw["tips-and-tricks-item"]["electric-pole-connections"])
    tip.name = "transformers"
    tip.tag = "[item=fluidic-transformer]"
    tip.trigger = {
        type = "sequence",
        triggers = {
            {
                type = "time-elapsed",
                ticks = 4 * 60 * 60 * 60 -- 4 hours
            },
            {
                type = "build-entity",
                entity = "fluidic-big-electric-pole-place",
                match_type_only = true,
                count = 5
            },
            {
                type = "build-entity",
                entity = "fluidic-transformer",
                match_type_only = true,
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
            if player.selected and not drawn then lib.render_all_connections(); drawn = true
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