data:extend
({   
    {
        type = "item",
        name = "fluidic-medium-pole-in",        
		icon_size = 64,
	    place_result = "fluidic-medium-pole-in",
        icon = "__base__/graphics/icons/medium-electric-pole.png",
		subgroup = "energy-pipe-distribution",
		order = "b[pipe]-b[duct]-a[duct-small]a",
        stack_size = 50
    },
})

local pole = table.deepcopy(data.raw["electric-pole"]["medium-electric-pole"])
override = {
    type = "assembling-machine",
    name = "fluidic-medium-pole-in",
    next_upgrade = nil,
    crafting_speed = 1,
    energy_usage = "10MW",
    module_specification = nil,
    allowed_effects = {},
    module_specification = { module_slots = 0 },
    energy_source = {
        type = "electric",
        input_priority = "secondary",
        usage_priority = "secondary-input",
        drain = "0kW"  
    },
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    drawing_box = {{-0.5, -2.8}, {0.5, 0.5}},
    maximum_wire_distance = 0,
    open_sound = nil,
    close_sound = nil,
    crafting_categories = {"fluid-kilojoule-generate"},
    fluid_boxes =
    { 
      {
        production_type = "output",        
        base_area = 10,
        base_level = 1,
        pipe_connections = {
            { type="input-output", position = {0, 1}, max_underground_distance = 10},
            { type="input-output", position = {0, -1}, max_underground_distance = 10},
            { type="input-output", position = {1, 0}, max_underground_distance = 10},
            { type="input-output", position = {-1, 0}, max_underground_distance = 10}
        },
        secondary_draw_orders = { north = -1 }
      },
    },
    animation =
    {
      layers =
      {
        {
            filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole.png",
            priority = "extra-high",
            width = 40,
            height = 124,
            direction_count = 4,
            shift = util.by_pixel(4, -44),
            hr_version =
            {
                filename = "__base__/graphics/entity/medium-electric-pole/hr-medium-electric-pole.png",
                priority = "extra-high",
                width = 84,
                height = 252,
                direction_count = 4,
                shift = util.by_pixel(3.5, -44),
                scale = 0.5
            }
        }
      }
    },
}
for k,v in pairs(override) do
    pole[k]=v
end
data:extend({pole})