data:extend
({   
    {
        type = "item",
        name = "fluidic-substation-in",        
	    place_result = "fluidic-substation-in",
		icon_size = 64,
        icon = "__base__/graphics/icons/substation.png",
		subgroup = "energy-pipe-distribution",
		order = "b[pipe]-b[duct]-a[duct-small]a",
        stack_size = 50
    },
    {
        type = "item",
        name = "fluidic-substation-out",
	    place_result = "fluidic-substation-out",
		icon_size = 64,
        icon = "__base__/graphics/icons/substation.png",
		subgroup = "energy-pipe-distribution",
		order = "b[pipe]-b[duct]-a[duct-small]a",
        stack_size = 50
    }
})

local pole = table.deepcopy(data.raw["electric-pole"]["substation"])
override = {
    type = "assembling-machine",
    name = "fluidic-substation-in",
    next_upgrade = nil,
    crafting_speed = 1,
    energy_usage = "30MW",
    module_specification = nil,
    allowed_effects = {},
    module_specification = { module_slots = 0 },
    energy_source = {
        type = "electric",
        input_priority = "secondary",
        usage_priority = "secondary-input",
        drain = "0kW"  
    },    
    maximum_wire_distance = 0,
    open_sound = nil,
    close_sound = nil,
    crafting_categories = {"fluidic-megajoule-generate"},
    fixed_recipe = "fluidic-megajoules-generate",
    fluid_boxes =
    { 
      {
        production_type = "output",        
        base_area = 1,
        base_level = 1,
        pipe_connections = {
            {type = "output", position = {-1.5, 0.5}, max_underground_distance = 10},
            {type = "output", position = {1.5, 0.5}, max_underground_distance = 10},
            {type = "output", position = {-0.5, 1.5}, max_underground_distance = 10},
            {type = "output", position = {-0.5, -1.5}, max_underground_distance = 10},
        },
        secondary_draw_orders = { north = -1 },
        filter = "megajoules"
      },
    },
    animation = pole.pictures,
}
for k,v in pairs(override) do
    pole[k]=v
end
data:extend({pole})

local pole = table.deepcopy(data.raw["electric-pole"]["substation"])
override = {
    type = "generator",
    name = "fluidic-substation-out",
    effectivity = 1,
    maximum_temperature = 15,
    fluid_usage_per_tick = 1,
    flow_length_in_ticks = 360,
    burns_fluid = true,
    two_direction_only = true,
    fluid_box =
    {
        base_area = 1,        
        pipe_connections =
        {
            {type = "input-output", position = {-1.5, 0.5}, max_underground_distance = 10},
            {type = "input-output", position = {1.5, 0.5}, max_underground_distance = 10},
            {type = "input-output", position = {-0.5, 1.5}, max_underground_distance = 10},
            {type = "input-output", position = {-0.5, -1.5}, max_underground_distance = 10},
        },
        production_type = "input-output",        
        minimum_temperature = 10,
        filter = "megajoules"
    },
    energy_source =
    {
        type = "electric",
        usage_priority = "secondary-output"
    },
    vertical_animation = pole.pictures,
    horizontal_animation = pole.pictures,
}
for k,v in pairs(override) do
    pole[k]=v
end
data:extend({pole})


local dummy = table.deepcopy(data.raw["electric-pole"]["substation"])
override = {    
    name = "fluidic-substation-dummy",
    selection_box = {{0,0},{0,0}},    
    maximum_wire_distance = 2,    
}
for k,v in pairs(override) do
    dummy[k]=v
end
data:extend({dummy})