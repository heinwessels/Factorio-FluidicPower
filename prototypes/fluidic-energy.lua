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
        icons = {
            {
                icon = "__FluidicPower__/graphics/icons/energy-fluid-base.png",
                icon_size = 64, icon_mipmaps = 4,
            },
        },
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
        icons = {
            {
                icon = "__FluidicPower__/graphics/icons/energy-fluid-base.png",
                icon_size = 64, icon_mipmaps = 4,
                shift = {-4, 0},
            },
            {
                icon = "__FluidicPower__/graphics/icons/energy-fluid-base.png",
                icon_size = 64, icon_mipmaps = 4,
                shift = {4, 0},
            },
        },
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
        icons = {
            {
                icon = "__FluidicPower__/graphics/icons/energy-fluid-base.png",
                icon_size = 64, icon_mipmaps = 4,
                shift = {-8, 0},
            },
            {
                icon = "__FluidicPower__/graphics/icons/energy-fluid-base.png",
                icon_size = 64, icon_mipmaps = 4,
                shift = {0, 0},
            },
            {
                icon = "__FluidicPower__/graphics/icons/energy-fluid-base.png",
                icon_size = 64, icon_mipmaps = 4,
                shift = {8, 0},
            },
        },
        order = "z[c]",
        subgroup = "fluidic-energy",
        auto_barrel = false -- That would be fun
    },
})
