data:extend
({   
    {
        type = "item",
        name = "fluidic-small-pole-in",
		icon_size = 64,
	    place_result = "fluidic-small-pole-in",
        icon = "__base__/graphics/icons/small-electric-pole.png",
		subgroup = "energy-pipe-distribution",
        order = "a[energy]-a[small-electric-pole]",
        stack_size = 50
    },
    {
        type = "item",
        name = "fluidic-small-pole-out",
		icon_size = 64,
	    place_result = "fluidic-small-pole-out",
        icon = "__base__/graphics/icons/small-electric-pole.png",
		subgroup = "energy-pipe-distribution",
        order = "a[energy]-a[small-electric-pole]",
        stack_size = 50
    }
})

local pole = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"])
override = {
    type = "generator",
    name = "fluidic-small-pole-out",
    minable = {mining_time = 0.5, result = "fluidic-small-pole-out"},
    effectivity = 1,
    maximum_temperature = 15,
    fluid_usage_per_tick = 1,
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
        minimum_temperature = 10,
        filter = "fluidic-10-kilojoules"
    },
    energy_source =
    {
        type = "electric",
        usage_priority = "tertiary"
    },
    vertical_animation = pole.pictures,
    horizontal_animation = pole.pictures,
}
for k,v in pairs(override) do
    pole[k]=v
end
data:extend({pole})

local pole = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"])
override = {
    type = "assembling-machine",
    name = "fluidic-small-pole-in",
    minable = {mining_time = 0.5, result = "fluidic-small-pole-in"},
    next_upgrade = nil,
    crafting_speed = 1,
    energy_usage = "20MW",
    module_specification = nil,
    allowed_effects = {},
    module_specification = { module_slots = 0 },
    energy_source = {
        type = "electric",
        input_priority = "secondary",
        usage_priority = "tertiary",
        drain = "0kW"  
    },
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    drawing_box = {{-0.5, -2.8}, {0.5, 0.5}},
    maximum_wire_distance = 0,
    open_sound = nil,
    close_sound = nil,
    fixed_recipe = "fluidic-10-kilojoules-generate",
    crafting_categories = {"fluidic-generate"},
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
        secondary_draw_orders = { north = -1 },
      },
    },
    animation = pole.pictures,
}
for k,v in pairs(override) do
    pole[k]=v
end
data:extend({pole})


local dummy = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"])
override = {    
    name = "fluidic-small-pole-dummy",
    maximum_wire_distance = 1,
    selection_box = {{0,0},{0,0}},
}
for k,v in pairs(override) do
    dummy[k]=v
end
data:extend({dummy})



data.raw["electric-pole"]["small-electric-pole"].hidden = true