-- Create item
local item = table.deepcopy(data.raw["item"]["power-switch"])
override = {
    name = "fluidic-power-switch",
    place_result = "fluidic-power-switch",
}
for k,v in pairs(override) do
    item[k]=v
end
data:extend({item})

-- Recipe
data:extend({util.merge{
  data.raw["recipe"]["power-switch"],
  {
      name = "fluidic-power-switch",
      result = "fluidic-power-switch",
  }
}})
data.raw["recipe"]["power-switch"].enabled = false

-- Create entity
data:extend({util.merge{
    data.raw["power-switch"]["power-switch"],
    {
      name = "fluidic-power-switch",
      type = "pump",
      minable = {result = "fluidic-power-switch"},
      
      pumping_speed = 83.3333333333333333333, -- x60 = 5000. Thus, either 50MW or 50GW transfer

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
      animations = {      
        north = data.raw["power-switch"]["power-switch"].power_on_animation,
        east = data.raw["power-switch"]["power-switch"].power_on_animation,
        south = data.raw["power-switch"]["power-switch"].power_on_animation,
        west = data.raw["power-switch"]["power-switch"].power_on_animation,
      },
      fluid_animation = {
          north = data.raw["power-switch"]["power-switch"].overlay_loop,
          east = data.raw["power-switch"]["power-switch"].overlay_loop,
          south = data.raw["power-switch"]["power-switch"].overlay_loop,
          west = data.raw["power-switch"]["power-switch"].overlay_loop,
      },
      glass_pictures = {
        north = data.raw["power-switch"]["power-switch"].overlay_loop,
        east = data.raw["power-switch"]["power-switch"].overlay_loop,
        south = data.raw["power-switch"]["power-switch"].overlay_loop,
        west = data.raw["power-switch"]["power-switch"].overlay_loop,
      },

      -- TODO Fix the circuit wire locations    
      circuit_wire_connection_points = circuit_connector_definitions["pump"].points,
      circuit_connector_sprites = circuit_connector_definitions["pump"].sprites,
      circuit_wire_max_distance = default_circuit_wire_max_distance      
    }
}})

-- TODO Fix this hacky way to have a static animation. This is lame.
-- TODO Fix power switch shadow too
for _,direction in pairs(data.raw["pump"]["fluidic-power-switch"].animations) do
  direction.layers[1].filename = "__FluidicPower__/graphics/entities/power-switch/power-switch.png"
  direction.layers[1].animation_speed = 0.4
  direction.layers[1].hr_version.filename = "__FluidicPower__/graphics/entities/power-switch/hr-power-switch.png"
  direction.layers[1].hr_version.animation_speed = 0.4
end

-- Disable vanilla entity
data.raw["recipe"]["power-switch"].enabled = false
data.raw["recipe"]["power-switch"].hidden = false
data.raw["item"]["power-switch"].flags = {"hidden"}