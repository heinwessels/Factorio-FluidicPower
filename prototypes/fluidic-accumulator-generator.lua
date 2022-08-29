
-- Recipe will be the vanilla accumulator recipe

-- Create the entity
local circuit_connections = circuit_connector_definitions.create(
    universal_connector_template,
    {
        { variation = 26, main_offset = util.by_pixel(18.5, 19), shadow_offset = util.by_pixel(20.5, 25.5), show_shadow = true },
        { variation = 26, main_offset = util.by_pixel(18.5, 19), shadow_offset = util.by_pixel(20.5, 25.5), show_shadow = true },
        { variation = 26, main_offset = util.by_pixel(18.5, 19), shadow_offset = util.by_pixel(20.5, 25.5), show_shadow = true },
        { variation = 26, main_offset = util.by_pixel(18.5, 19), shadow_offset = util.by_pixel(20.5, 25.5), show_shadow = true },
    }
)
local entity = data.raw["accumulator"]["accumulator"]
local tank = data.raw["storage-tank"]["storage-tank"]


local Generator = { }

function Generator.create_accumulator(context)

    local name = "fluidic-"..context.base_name

    -- Item will be the base item (for compatability)
    data.raw.item[context.base_name].place_result = name

    -- Create entity
    local tank = data.raw["storage-tank"]["storage-tank"]
    data:extend({
        util.merge{
            data.raw.accumulator[context.base_name],
            {
                name = name,
                type = "storage-tank",
                minable = {mining_time = 0.5, result = context.base_name},
                flow_length_in_ticks = 360,
                fluid_box =
                {
                    -- Energy Storage = base_area x fluid_unit x 100 = 5000 kJ
                    -- So basically it's the contents of 5 poles in a 2x2 area.
                    -- Not very efficient, but how vanilla works.
                    base_area = 5,
                    filter = "fluidic-10-kilojoules",      
                    pipe_connections =
                    {
                        {type = "input-output", position = {-1.5, -0.5}, max_underground_distance = 1},
                        {type = "input-output", position = {1.5, -0.5}, max_underground_distance = 1},
                        {type = "input-output", position = { -0.5, -1.5,}, max_underground_distance = 1},
                        {type = "input-output", position = { -0.5, 1.5}, max_underground_distance = 1},
                    }
                },
                rotatable = false,
                window_bounding_box = {{-0.2, 0.3}, {-0.4, 0.7}},
                pictures = {
                    picture = table.deepcopy(entity.picture),
                    fluid_background = tank.pictures.fluid_background,
                    window_background = tank.pictures.window_background,
                    flow_sprite = tank.pictures.flow_sprite,
                    gas_flow = tank.pictures.gas_flow,
                },    
                circuit_wire_connection_points = circuit_connections.points,
                circuit_connector_sprites = circuit_connections.sprites,
                circuit_wire_max_distance = default_circuit_wire_max_distance,            
            }
        },
    })

    accu = data.raw["storage-tank"][name]

    table.insert(accu.flags, "not-rotatable")
    if settings.startup["fluidic-disable-accumulator-alt-info"].value then
        table.insert(accu.flags, "hide-alt-info")
    end

    return accu
end

return Generator