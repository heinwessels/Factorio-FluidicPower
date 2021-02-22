data:extend
({   
    {
        type = "recipe-category",
        name = "fluidic-kilojoule-generate"
    },
    {
        type = "recipe-category",
        name = "fluidic-megajoule-generate"
    },
    {
        type = "recipe-category",
        name = "fluidic-transformers-step-up"
    },
    {
        type = "recipe-category",
        name = "fluidic-transformers-step-down"
    },    
    {
        type = "fluid",
        name = "kilojoules",
        default_temperature = 15,
        max_temperature = 15,
        fuel_value = "1kJ",
        heat_capacity = "1KJ",
        base_color = {r=0, g=1, b=0},
        flow_color = {r=0, g=1, b=0},
        icon = "__base__/graphics/icons/list-dot.png",
        icon_size = 64, icon_mipmaps = 4,
        order = "a[kilojoules]-a[kilojoules]",
        -- hidden = true
    },
    {
        type = "fluid",
        name = "megajoules",
        default_temperature = 15,
        max_temperature = 15,
        fuel_value = "1MJ",
        heat_capacity = "1MJ",
        base_color = {r=0, g=1, b=0},
        flow_color = {r=0, g=1, b=0},
        icon = "__base__/graphics/icons/list-dot.png",
        icon_size = 64, icon_mipmaps = 4,
        order = "a[megajoules]-a[megajoules]",
        -- hidden = true
    },
    {
        type = "fluid",
        name = "gigajoules",
        default_temperature = 15,
        max_temperature = 15,
        fuel_value = "1GJ",
        heat_capacity = "1GJ",
        base_color = {r=0, g=1, b=0},
        flow_color = {r=0, g=1, b=0},
        icon = "__base__/graphics/icons/list-dot.png",
        icon_size = 64, icon_mipmaps = 4,
        order = "a[gigajoules]-a[gigajoules]",
        -- hidden = true     
    },


    {
        type = "recipe",
        name = "fluidic-kilojoules-generate",
        icon_size = 64,
        icon = "__base__/graphics/icons/list-dot.png",
        category = "fluidic-kilojoule-generate",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={},
        energy_required = 0.05,
        results={{type="fluid", name="kilojoules", amount=500}},        
    },
    {
        type = "recipe",
        name = "fluidic-megajoules-generate",        
        icon_size = 64,
        icon = "__base__/graphics/icons/list-dot.png",
        category = "fluidic-megajoule-generate",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={},
        energy_required = 1,
        results={{type="fluid", name="megajoules", amount=30}},
    },
    
    {
        type = "recipe",
        name = "kilo-to-megajoules",        
        icon_size = 64,
        icon = "__base__/graphics/icons/list-dot.png",
        category = "fluidic-transformers-step-up",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={{type="fluid", name="kilojoules", amount=1000}},
        energy_required = 0.01,
        results={{type="fluid", name="megajoules", amount=1}},        
    },
    {
        type = "recipe",
        name = "mega-to-gigajoules",        
        icon_size = 64,
        icon = "__base__/graphics/icons/list-dot.png",
        category = "fluidic-transformers-step-up",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={{type="fluid", name="megajoules", amount=1000}},
        energy_required = 0.01,
        results={{type="fluid", name="gigajoules", amount=1}},        
    },
    {
        type = "recipe",
        name = "mega-to-kilojoules",        
        icon_size = 64,
        icon = "__base__/graphics/icons/list-dot.png",
        category = "fluidic-transformers-step-down",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={{type="fluid", name="megajoules", amount=1}},
        energy_required = 0.1,
        results={{type="fluid", name="kilojoules", amount=1000}},        
    },
    {
        type = "recipe",
        name = "giga-to-megajoules",        
        icon_size = 64,
        icon = "__base__/graphics/icons/list-dot.png",
        category = "fluidic-transformers-step-down",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={{type="fluid", name="gigajoules", amount=1}},
        energy_required = 0.1,
        results={{type="fluid", name="megajoules", amount=1000}},        
    }
})