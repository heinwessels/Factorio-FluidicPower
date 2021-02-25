data:extend
({   
    {
        type = "recipe-category",
        name = "fluidic-generate"
    },    
    {
        type = "fluid",
        name = "fluidic-kilojoules",
        default_temperature = 15,
        max_temperature = 15,
        fuel_value = "1kJ",
        heat_capacity = "1KJ",
        base_color = {r=0, g=1, b=0},
        flow_color = {r=0, g=1, b=0},
        icon = "__base__/graphics/icons/list-dot.png",
        icon_size = 64, icon_mipmaps = 4,
        order = "a[kilojoules]-a[kilojoules]",
        hidden = true
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
        icon = "__base__/graphics/icons/list-dot.png",
        icon_size = 64, icon_mipmaps = 4,
        order = "a[kilojoules]-a[kilojoules]",
        hidden = true
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
        icon = "__base__/graphics/icons/list-dot.png",
        icon_size = 64, icon_mipmaps = 4,
        order = "a[megajoules]-a[megajoules]",
        hidden = true
    },
    {
        type = "fluid",
        name = "fluidic-gigajoules",
        default_temperature = 15,
        max_temperature = 15,
        fuel_value = "1GJ",
        heat_capacity = "1GJ",
        base_color = {r=0, g=1, b=0},
        flow_color = {r=0, g=1, b=0},
        icon = "__base__/graphics/icons/list-dot.png",
        icon_size = 64, icon_mipmaps = 4,
        order = "a[gigajoules]-a[gigajoules]",
        hidden = true
    },


    {
        type = "recipe",
        name = "fluidic-kilojoules-generate",
        icon_size = 64,
        icon = "__base__/graphics/icons/list-dot.png",
        category = "fluidic-generate",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={},
        energy_required = 0.05,
        results={{type="fluid", name="fluidic-kilojoules", amount=500}},  
        hidden = true      
    },
    {
        type = "recipe",
        name = "fluidic-10-kilojoules-generate",
        icon_size = 64,
        icon = "__base__/graphics/icons/list-dot.png",
        category = "fluidic-generate",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={},
        energy_required = 0.5,
        results={{type="fluid", name="fluidic-10-kilojoules", amount=100}},      
        hidden = true  
    },
    {
        type = "recipe",
        name = "fluidic-megajoules-generate",        
        icon_size = 64,
        icon = "__base__/graphics/icons/list-dot.png",
        category = "fluidic-generate",
        subgroup = "energy-pipe-distribution",
        order = "a[kilojoules]-a[kilojoules]",        
        ingredients ={},
        energy_required = 1,
        results={{type="fluid", name="fluidic-megajoules", amount=30}},
        hidden = true
    },
})