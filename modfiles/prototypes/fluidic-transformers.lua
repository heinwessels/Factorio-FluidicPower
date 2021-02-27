local item = table.deepcopy(data.raw["item"]["substation"])
override = {
    name = "fluidic-transformer-step-up",
    place_result = "fluidic-transformer-step-up",
    -- TODO Give different icon than substation
}
for k,v in pairs(override) do
    item[k]=v
end
data:extend({item})

local item = table.deepcopy(data.raw["item"]["substation"])
override = {
    name = "fluidic-transformer-step-down",
    place_result = "fluidic-transformer-step-down",
    -- TODO Give different icon than substation
}
for k,v in pairs(override) do
    item[k]=v
end
data:extend({item})

data:extend
({ 
    ------------------------
    -- Transformer recipes
    ------------------------
    {
        type = "recipe",
        name = "fluidic-transformer-step-up",
        enabled = false,
        ingredients =
        {
            {"steel-plate", 10},
            {"advanced-circuit", 5},
            {"copper-cable", 20}
        },
        result = "fluidic-transformer-step-up"
    },
    {
        type = "recipe",
        name = "fluidic-transformer-step-down",
        enabled = false,
        ingredients =
        {
            {"steel-plate", 10},
            {"advanced-circuit", 5},
            {"copper-cable", 20}
        },
        result = "fluidic-transformer-step-down"
    },

    ------------------------
    -- STEP UP POWER RECIPES
    ------------------------
    {
        type = "recipe-category",
        name = "fluidic-transformers-step-up"
    },
    {
        type = "recipe",
        name = "fluidic-10-kilo-to-megajoules",        
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-2-up-icon.png",
        category = "fluidic-transformers-step-up",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={{type="fluid", name="fluidic-10-kilojoules", amount=1000}},
        energy_required = 0.1,
        results={{type="fluid", name="fluidic-10-megajoules", amount=1}},
        hidden = true
    },
    {
        type = "recipe",
        name = "fluidic-mega-to-gigajoules",        
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-3-up-icon.png",
        category = "fluidic-transformers-step-up",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={{type="fluid", name="fluidic-10-megajoules", amount=100}},
        energy_required = 0.1,
        results={{type="fluid", name="fluidic-gigajoules", amount=1}},
        hidden = true
    },

    ------------------------
    -- STEP DOWN POWER RECIPES
    ------------------------
    {
        type = "recipe-category",
        name = "fluidic-transformers-step-down"
    },  
    {
        type = "recipe",
        name = "fluidic-10-mega-to-10-kilojoules",        
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-1-down-icon.png",
        category = "fluidic-transformers-step-down",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={{type="fluid", name="fluidic-10-megajoules", amount=1}},
        energy_required = 0.1,
        results={{type="fluid", name="fluidic-10-kilojoules", amount=1000}},
        hidden = true
    },
    {
        type = "recipe",
        name = "fluidic-giga-to-10-megajoule",        
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-2-down-icon.png",
        category = "fluidic-transformers-step-down",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={{type="fluid", name="fluidic-gigajoules", amount=1}},
        energy_required = 0.1,
        results={{type="fluid", name="fluidic-10-megajoules", amount=100}},
        hidden = true
    }
})

local transformer_up = table.deepcopy(data.raw["electric-pole"]["substation"])
override = {
    type = "furnace",
    name = "fluidic-transformer-step-up",
    mode = "output-to-separate-pipe",
    crafting_categories = {"fluidic-transformers-step-up"},
    minable = {mining_time = 0.2, result = "fluidic-transformer-step-up"},
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
        base_area = 1,
        base_level = 1,
        pipe_connections = {
            {type = "output", position = {1.5, 0.5}, max_underground_distance = 10},        
            {type = "output", position = {1.5, -0.5}, max_underground_distance = 10},
        },        
      },
    },
    animation = transformer_up.pictures,
}
for k,v in pairs(override) do
    transformer_up[k]=v
end
data:extend({transformer_up})


local transformer_down = table.deepcopy(data.raw["furnace"]["fluidic-transformer-step-up"])
override = {
    name = "fluidic-transformer-step-down",
    crafting_categories = {"fluidic-transformers-step-down"},
    minable = {mining_time = 0.2, result = "fluidic-transformer-step-down"},
}
for k,v in pairs(override) do
    transformer_down[k]=v
end
transformer_down.fluid_boxes[1].base_area = 1
transformer_down.fluid_boxes[2].base_area = 10
data:extend({transformer_down})