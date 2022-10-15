util = require("util")
local Generator = { }

function Generator.create_accumulator(context)

    local name = "fluidic-"..context.base_name
    local base_entity = data.raw.accumulator[context.base_name]
    context.fluid_filter = context.fluid_filter or "fluidic-10-kilojoules"

    -- Item will be the base item (for compatability)
    data.raw.item[context.base_name].place_result = name

    -- We assume the accumulator is square, and centered on the center :P
    -- And put a fluidbox-connection at every spot
    local fluid_base_divider = 100 * util.parse_energy(data.raw.fluid[context.fluid_filter].fuel_value)
    local size = math.ceil(base_entity.collision_box[2][1]) - 0.5
    local pipe_connections = {}
    for offset = -size, size do
        table.insert(pipe_connections,
            {type = "input-output", position = {-size-1, -offset}, max_underground_distance = 1})            
        table.insert(pipe_connections, 
            {type = "input-output", position = {size+1, -offset}, max_underground_distance = 1})
        table.insert(pipe_connections, 
            {type = "input-output", position = { -offset, -size-1}, max_underground_distance = 1})
        table.insert(pipe_connections, 
            {type = "input-output", position = { -offset, size+1}, max_underground_distance = 1})
    end

    -- Create entity
    local tank = data.raw["storage-tank"]["storage-tank"]
    local accumulator = {
        type = "storage-tank",
        name = name,
        localised_name = {"entity-name."..context.base_name},
        localised_description={"", 
            {"fluidic-text.accumulator"}, 
            {"fluidic-text.accumulator-rating", base_entity.energy_source.buffer_capacity}
        },
        icon = base_entity.icon,
        icon_size = base_entity.icon_size, 
        icon_mipmaps = base_entity.icon_mipmaps,
        flags = base_entity.flags,
        minable = {mining_time = base_entity.minable.mining_time, result = context.base_name},
        max_health = base_entity.max_health,
        corpse = base_entity.corpse,
        dying_explosion = base_entity.dying_explosion,
        collision_box = base_entity.collision_box,
        selection_box = base_entity.selection_box,
        damaged_trigger_effect = base_entity.damaged_trigger_effect,
        fluid_box = {
            base_area = util.parse_energy(base_entity.energy_source.buffer_capacity) / fluid_base_divider,
            filter = context.fluid_filter,
            hide_connection_info = true,
            pipe_connections = pipe_connections,
        },
        window_bounding_box = {{0, 0}, {0, 0}},
        pictures = {
            picture = base_entity.picture,
            fluid_background = tank.pictures.fluid_background,
            window_background = tank.pictures.window_background,
            flow_sprite = tank.pictures.flow_sprite,
            gas_flow = tank.pictures.gas_flow,
        },
        flow_length_in_ticks = 360,
        vehicle_impact_sound = base_entity.vehicle_impact_sound,
        open_sound = base_entity.open_sound,
        close_sound = base_entity.close_sound,
        working_sound = base_entity.working_sound,
        circuit_wire_connection_points = {
            base_entity.circuit_wire_connection_point,
            base_entity.circuit_wire_connection_point,
            base_entity.circuit_wire_connection_point,
            base_entity.circuit_wire_connection_point,
        },
        circuit_connector_sprites = {
            base_entity.circuit_connector_sprites,
            base_entity.circuit_connector_sprites,
            base_entity.circuit_connector_sprites,
            base_entity.circuit_connector_sprites,
        },
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        water_reflection = base_entity.water_reflection
    }
      
    table.insert(accumulator.flags, "not-rotatable")
    if settings.startup["fluidic-disable-accumulator-alt-info"].value then
        table.insert(accu.flags, "hide-alt-info")
    end
    
    data:extend({accumulator})
    
    -- Add "no-no" message to now-hidden entity
    data.raw.accumulator[context.base_name].localised_description = {"fluidic-text.non-accessable"}
    
    return accumulator
end

return Generator