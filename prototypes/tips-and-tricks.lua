local poles = require("scripts.fluidic-handle-poles")
local overlay = require("scripts.overlay")
local config = require("config")

-- Build generic setup code for basic functionality during simulations
local function setup()
    return [[
        local config = load([=[]]..serpent.dump(config)..[[]=])()

        
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
            if electric_variant then
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
            if fluid_variant then
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

        function lib.render_connection(this, that, ctx)
            ctx = ctx or { }
            local line_format
            if ctx.high_voltage then
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
            if ctx.mixed then line_format.colour = {r = 1,  g = 0, b = 0, a = 0} end
            
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

    ]]
end

do
    local sim = data.raw["tips-and-tricks-item"]["electric-pole-connections"].simulation
    sim.init = [[
        ]]..setup()..[[

        game.surfaces.nauvis.daytime = 1
        local player = game.create_test_player{name = "Elvis"}
        player.character.teleport{0, 1}
        game.camera_player = player
        game.camera_zoom = 1.5
        game.camera_player_cursor_position = player.position        
        local surface = game.surfaces[1]

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

        script.on_nth_tick(1, function() 
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
                    lib.render_connection(one, two)
                    lib.render_connection(two, three)
                    counter = 90
                    state = "wait-overlay"
                end
            elseif state == "wait-overlay" then
                counter = counter - 1
                if counter <= 0 then
                    rendering.clear()
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
    -- data.raw["tips-and-tricks-item"]["electric-pole-connections"] = { simulation = { }}
    -- local item = 
end