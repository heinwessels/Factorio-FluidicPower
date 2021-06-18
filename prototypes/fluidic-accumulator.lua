-- Item will be the vanilla accumulator item (for compatability)
data.raw.item.accumulator.place_result = "fluidic-accumulator"
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
local entity = table.deepcopy(data.raw["accumulator"]["accumulator"])
local tank = table.deepcopy(data.raw["storage-tank"]["storage-tank"])
override = {
    name = "fluidic-accumulator",
    type = "storage-tank",
    minable = {mining_time = 0.5, result = "accumulator"},
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
        fluid_background = table.deepcopy(tank.pictures.fluid_background),
        window_background = table.deepcopy(tank.pictures.window_background),
        flow_sprite = table.deepcopy(tank.pictures.flow_sprite),
        gas_flow = table.deepcopy(tank.pictures.gas_flow),
    },    
    circuit_wire_connection_points = circuit_connections.points,
    circuit_connector_sprites = circuit_connections.sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance,   
}
override.pictures.picture.layers[1].filename = "__FluidicPower__/graphics/entities/accumulator/accumulator.png"
override.pictures.picture.layers[1].hr_version.filename = "__FluidicPower__/graphics/entities/accumulator/hr-accumulator.png"
for k,v in pairs(override) do
    entity[k]=v
end
data:extend({entity})
table.insert(data.raw["storage-tank"]["fluidic-accumulator"].flags, "not-rotatable")
if settings.startup["fluidic-disable-accumulator-alt-info"].value then
    table.insert(data.raw["storage-tank"]["fluidic-accumulator"].flags, "hide-alt-info")
end