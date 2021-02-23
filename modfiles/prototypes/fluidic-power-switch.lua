local item = table.deepcopy(data.raw["item"]["power-switch"])
override = {
    name = "fluidic-power-switch",
    place_result = "fluidic-power-switch",
}
for k,v in pairs(override) do
    item[k]=v
end
data:extend({item})

local entity = table.deepcopy(data.raw["power-switch"]["power-switch"])
local pump = table.deepcopy(data.raw["power-switch"]["power-switch"])
override = {
    name = "fluidic-power-switch",
    type = "pump",
    place_result = "fluidic-power-switch",

    fluid_wagon_connector_graphics = nil,
    fluid_wagon_connector_frame_count = nil,
    fluid_wagon_connector_alignment_tolerance = nil,
    fluid_wagon_connector_speed = nil,

    fluid_box =
    {
      base_area = 1,
      pipe_connections =
      {
        { position = {-0.5, -1.5}, type="output", max_underground_distance = 10 },
        { position = {0.5, -1.5}, type="output", max_underground_distance = 10 },
        { position = {-0.5, 1.5}, type="input", max_underground_distance = 10 },
        { position = {0.5, 1.5}, type="input", max_underground_distance = 10 },
      }
    },
    energy_source =
    {
      type = "void",
    },
    energy_usage = "1W",
    pumping_speed = 200,
    animations = {
        north = entity.power_on_animation,
        east = entity.power_on_animation,
        south = entity.power_on_animation,
        west = entity.power_on_animation,
    },
    fluid_animation = {
        north = entity.overlay_loop,
        east = entity.overlay_loop,
        south = entity.overlay_loop,
        west = entity.overlay_loop,
    },
    -- Fix this!
    glass_pictures = {
      north = entity.overlay_loop,
      east = entity.overlay_loop,
      south = entity.overlay_loop,
      west = entity.overlay_loop,
    },
    circuit_wire_connection_points = circuit_connector_definitions["pump"].points,
    circuit_connector_sprites = circuit_connector_definitions["pump"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
}
for k,v in pairs(override) do
    entity[k]=v
end
data:extend({entity})