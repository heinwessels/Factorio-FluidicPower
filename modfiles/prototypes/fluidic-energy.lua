data:extend
({   
    {
        type = "recipe-category",
        name = "fluidic-generate"
    },
    {
        type = "item-subgroup",
        name = "fluidic-energy",
        group = "fluids",
        order = "z"
    },
    {
        type = "fluid",
        name = "fluidic-10-kilojoules",
        default_temperature = 15,
        max_temperature = 15,
        fuel_value = "10kJ",
        heat_capacity = "10KJ",
        base_color = {r=0, g=1, b=0},
        flow_color = {r=0, g=1, b=0},
        icon = "__FluidicPower__/graphics/icons/fluidic-level-1-icon.png",
        icon_size = 64, icon_mipmaps = 4,
        order = "z[a]",
        subgroup = "fluidic-energy",
        auto_barrel = false -- That would be fun
    },
    {
        type = "fluid",
        name = "fluidic-megajoules",
        default_temperature = 15,
        max_temperature = 15,
        fuel_value = "1MJ",
        heat_capacity = "1MJ",
        base_color = {r=0, g=1, b=0},
        flow_color = {r=0, g=1, b=0},
        icon = "__FluidicPower__/graphics/icons/fluidic-level-2-icon.png",
        icon_size = 64, icon_mipmaps = 4,
        order = "z[b]",
        subgroup = "fluidic-energy",
        auto_barrel = false -- That would be fun
    },
    {
        type = "fluid",
        name = "fluidic-100-megajoules",
        default_temperature = 15,
        max_temperature = 15,
        fuel_value = "100MJ",
        heat_capacity = "100MJ",
        base_color = {r=0, g=1, b=0},
        flow_color = {r=0, g=1, b=0},
        icon = "__FluidicPower__/graphics/icons/fluidic-level-3-icon.png",
        icon_size = 64, icon_mipmaps = 4,
        order = "z[c]",
        subgroup = "fluidic-energy",
        auto_barrel = false -- That would be fun
    },

    -- Here is a formula to show the correlation between
    -- the recipe and the requried assembler energy usage
    --      P = Assembler power usage in Watt
    --      i = energy of input unit in Joule        
    --      n = Amount of units produced per craft
    --      t = Time required per craft
    -- Then:
    --      P = ( i * n ) / t
    {
        type = "recipe",
        name = "fluidic-10-kilojoules-generate-small",
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-1-generate-icon.png",
        category = "fluidic-generate",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={},
        energy_required = 0.5,
        results={{type="fluid", name="fluidic-10-kilojoules", amount=250}},
        scale_entity_info_icon = true,
        hidden = true  
    },
    {
        type = "recipe",
        name = "fluidic-10-kilojoules-generate-medium",
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-1-generate-icon.png",
        category = "fluidic-generate",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={},
        energy_required = 0.25,
        results={{type="fluid", name="fluidic-10-kilojoules", amount=750}},
        hidden = true  
    },
    {
        type = "recipe",
        name = "fluidic-10-kilojoules-generate-substation",
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-1-generate-icon.png",
        category = "fluidic-generate",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={},
        energy_required = 0.25,
        results={{type="fluid", name="fluidic-10-kilojoules", amount=1000}},      
        hidden = true  
    },
})