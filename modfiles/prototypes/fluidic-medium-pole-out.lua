data:extend
({   
    {
        type = "item",
        name = "fluidic-medium-pole-out",
		icon_size = 64,
	    place_result = "fluidic-medium-pole-out",
        icon = "__base__/graphics/icons/medium-electric-pole.png",
		subgroup = "energy-pipe-distribution",
		order = "b[pipe]-b[duct]-a[duct-small]a",
        stack_size = 50
    }
})

local pole = table.deepcopy(data.raw["electric-pole"]["medium-electric-pole"])
override = {
    type = "generator",
    name = "fluidic-medium-pole-out",
    effectivity = 1,
    maximum_temperature = 15,
    fluid_usage_per_tick = 100,
    flow_length_in_ticks = 360,
    burns_fluid = true,
    two_direction_only = true,
    fluid_box =
    {
        base_area = 10,            
        pipe_connections =
        {
            {type = "input-output", position = {-1, 0}, max_underground_distance = 10},
            {type = "input-output", position = {1, 0}, max_underground_distance = 10},
            {type = "input-output", position = {0, -1}, max_underground_distance = 10},
            {type = "input-output", position = {0, 1}, max_underground_distance = 10},
        },
        production_type = "input-output",
        filter = "kilojoules",
        minimum_temperature = 10   
    },
    energy_source =
    {
        type = "electric",
        usage_priority = "secondary-output"
    },
    horizontal_animation =
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
                },
                {
                filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole-shadow.png",
                priority = "extra-high",
                width = 140,
                height = 32,
                direction_count = 4,
                shift = util.by_pixel(56, -1),
                draw_as_shadow = true,
                hr_version =
                {
                    filename = "__base__/graphics/entity/medium-electric-pole/hr-medium-electric-pole-shadow.png",
                    priority = "extra-high",
                    width = 280,
                    height = 64,
                    direction_count = 4,
                    shift = util.by_pixel(56.5, -1),
                    draw_as_shadow = true,
                    scale = 0.5
                }
                }
        }
    },
    vertical_animation =
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
                },
                {
                filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole-shadow.png",
                priority = "extra-high",
                width = 140,
                height = 32,
                direction_count = 4,
                shift = util.by_pixel(56, -1),
                draw_as_shadow = true,
                hr_version =
                {
                    filename = "__base__/graphics/entity/medium-electric-pole/hr-medium-electric-pole-shadow.png",
                    priority = "extra-high",
                    width = 280,
                    height = 64,
                    direction_count = 4,
                    shift = util.by_pixel(56.5, -1),
                    draw_as_shadow = true,
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



local dummy = table.deepcopy(data.raw["electric-pole"]["medium-electric-pole"])
override = {    
    name = "fluidic-medium-pole-dummy",    
    selection_box = {{0,0},{0,0}},    
    maximum_wire_distance = 1,    
}
for k,v in pairs(override) do
    dummy[k]=v
end
data:extend({dummy})