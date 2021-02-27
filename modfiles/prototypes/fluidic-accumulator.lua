local item = table.deepcopy(data.raw["item"]["accumulator"])
override = {
    name = "fluidic-accumulator",
    place_result = "fluidic-accumulator",
}
for k,v in pairs(override) do
    item[k]=v
end
data:extend({item})

local entity = table.deepcopy(data.raw["accumulator"]["accumulator"])
local tank = table.deepcopy(data.raw["storage-tank"]["storage-tank"])
override = {
    name = "fluidic-accumulator",
    type = "storage-tank",
    minable = {mining_time = 0.5, result = "fluidic-accumulator"},
    flow_length_in_ticks = 360,
    fluid_box =
    {
      base_area = 50,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        {type = "input-output", position = {-1.5, 0.5}, max_underground_distance = 1},
        {type = "input-output", position = {1.5, 0.5}, max_underground_distance = 1},
        {type = "input-output", position = {-0.5, 1.5}, max_underground_distance = 1},
        {type = "input-output", position = {-0.5, -1.5}, max_underground_distance = 1},

        -- TODO Remove these connections so it looks like the substation
        -- Need to solve the issue of not showing pipe connections
        -- And need storage tank for circuit network
        {type = "input-output", position = {-1.5, -0.5}, max_underground_distance = 1},
        {type = "input-output", position = {1.5, -0.5}, max_underground_distance = 1},
        {type = "input-output", position = {0.5, 1.5}, max_underground_distance = 1},
        {type = "input-output", position = {0.5, -1.5}, max_underground_distance = 1},
      }
    },
    window_bounding_box = {{-0.2, 0.3}, {-0.4, 0.7}},
    pictures = {
        picture = table.deepcopy(entity.picture),
        fluid_background = table.deepcopy(tank.pictures.fluid_background),
        window_background = table.deepcopy(tank.pictures.window_background),
        flow_sprite = table.deepcopy(tank.pictures.flow_sprite),
        gas_flow = table.deepcopy(tank.pictures.gas_flow),
    },
    -- Use Accumulator's sprites and such.
    circuit_wire_connection_points = circuit_connector_definitions["storage-tank"].points,
    circuit_connector_sprites = circuit_connector_definitions["storage-tank"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance,   
}
override.pictures.picture.layers[1].filename = "__FluidicPower__/graphics/entities/accumulator/accumulator.png"
override.pictures.picture.layers[1].hr_version.filename = "__FluidicPower__/graphics/entities/accumulator/hr-accumulator.png"
for k,v in pairs(override) do
    entity[k]=v
end
data:extend({entity})