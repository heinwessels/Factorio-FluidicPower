data:extend
({   
    {
        type = "item",
        name = "fluidic-step-up-transformer",
		icon_size = 64,
	    place_result = "fluidic-step-up-transformer",
        icon = "__base__/graphics/icons/substation.png",
		subgroup = "energy-pipe-distribution",
        order = "a[energy]-a[step-up-transformer]",
        stack_size = 50
    },
    {
        type = "item",
        name = "fluidic-step-down-transformer",
		icon_size = 64,
	    place_result = "fluidic-step-down-transformer",
        icon = "__base__/graphics/icons/substation.png",
		subgroup = "energy-pipe-distribution",
        order = "a[energy]-a[step-down-transformer]",
        stack_size = 50
    },
})

local transformer = table.deepcopy(data.raw["electric-pole"]["substation"])
override = {
    type = "furnace",
    name = "fluidic-step-up-transformer",
    mode = "output-to-separate-pipe",
    crafting_categories = {"fluidic-transformers-step-up"},   
    energy_usage = "10kW",
    allowed_effects = {},
    energy_source = nil,
    module_specification = {module_slots=0},
    crafting_speed = 1,
    source_inventory_size = 1,
    result_inventory_size = 0,
    energy_source = {
        type = "void",        
        drain = "0kW"    
    },
    fluid_boxes =
    { 
      {
        production_type = "input",        
        base_area = 10,
        base_level = -1,
        height = 2,
        pipe_connections = {
            {type = "input", position = {-1.5, 0.5}, max_underground_distance = 10},        
            {type = "input", position = {-1.5, -0.5}, max_underground_distance = 10},
        },        
      },
      {
        production_type = "output",        
        base_area = 10,
        base_level = 1,
        pipe_connections = {
            {type = "output", position = {1.5, 0.5}, max_underground_distance = 10},        
            {type = "output", position = {1.5, -0.5}, max_underground_distance = 10},
        },        
      },
    },
    animation = transformer.pictures,
}
for k,v in pairs(override) do
    transformer[k]=v
end
data:extend({transformer})


local transformer2 = table.deepcopy(data.raw["furnace"]["fluidic-step-up-transformer"])
override = {
    name = "fluidic-step-down-transformer",    
    crafting_categories = {"fluidic-transformers-step-down"},    
}
for k,v in pairs(override) do
    transformer2[k]=v
end
data:extend({transformer2})