-- Create item
data:extend({
    util.merge{
        data.raw["item"]["substation"],
        {
            name = "fluidic-transformer",
            place_result = "fluidic-transformer",
            icon = "__FluidicPower__/graphics/icons/transformer-icon.png",
            icon_size = 32,
        }
    },    
})

-- Create some recipes
data:extend
({ 
    ------------------------
    -- Transformer recipes
    ------------------------
    {
        type = "recipe",
        name = "fluidic-transformer",
        enabled = false,
        ingredients =
        {
            {"steel-plate", 10},
            {"advanced-circuit", 5},
            {"copper-cable", 20}
        },
        result = "fluidic-transformer"
    },

    ------------------------
    -- TRANSFORMER RECIPES
    ------------------------
    {
        type = "recipe-category",
        name = "fluidic-transformers"
    },
    {
        type = "recipe",
        name = "fluidic-10-kilo-to-megajoules",        
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-2-up-icon.png",
        category = "fluidic-transformers",
        order = "a[a]-a[a]",
        ingredients ={{type="fluid", name="fluidic-10-kilojoules", amount=1000}},
        energy_required = 0.2,
        results={{type="fluid", name="fluidic-10-megajoules", amount=1}},
        scale_entity_info_icon = true,        
        hide_from_stats = true, -- Hide stats to not influence production/consumption stats
    },
    {
        type = "recipe",
        name = "fluidic-mega-to-gigajoules",        
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-3-up-icon.png",
        order = "a[c]-a[gigajoules]",
        category = "fluidic-transformers",
        ingredients ={{type="fluid", name="fluidic-10-megajoules", amount=100}},
        energy_required = 0.2,
        results={{type="fluid", name="fluidic-gigajoules", amount=1}},
        scale_entity_info_icon = true,
        hide_from_stats = true, -- Hide stats to not influence production/consumption stats
    },    
    {
        type = "recipe",
        name = "fluidic-10-mega-to-10-kilojoules",        
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-1-down-icon.png",
        order = "a[b]-a[b]",
        category = "fluidic-transformers",
        ingredients ={{type="fluid", name="fluidic-10-megajoules", amount=1}},
        energy_required = 0.2,
        results={{type="fluid", name="fluidic-10-kilojoules", amount=1000}},
        scale_entity_info_icon = true,
        hide_from_stats = true, -- Hide stats to not influence production/consumption stats
    },
    {
        type = "recipe",
        name = "fluidic-giga-to-10-megajoule",        
        icon_size = 64,
        icon = "__FluidicPower__/graphics/icons/fluidic-level-2-down-icon.png",
        category = "fluidic-transformers",
        order = "a[d]-a[megajoules]",
        ingredients ={{type="fluid", name="fluidic-gigajoules", amount=1}},
        energy_required = 0.2,
        results={{type="fluid", name="fluidic-10-megajoules", amount=100}},
        scale_entity_info_icon = true,
        hide_from_stats = true, -- Hide stats to not influence production/consumption stats
    }
})

-- Creat the entities
data:extend({util.merge{
    -- This is a weird legacy hack where we use the accumulator shape, but create
    -- a furnace with fluid inputs, using old beacon graphics. Don't judge me.
    data.raw["electric-pole"]["substation"],
    {
        type = "assembling-machine",
        name = "fluidic-transformer",
        mode = "output-to-separate-pipe",
        crafting_categories = {"fluidic-transformers"},
        minable = {result = "fluidic-transformer"},
        energy_usage = "10kW",
        allowed_effects = {},
        energy_source = nil,
        module_specification = {module_slots=0},
        crafting_speed = 1,        
        energy_source = {
            type = "void",        
            drain = "0kW"    
        },
        fluid_boxes =
        {
            -- Would like to have less fluid connections here, 
            -- similar to big poles, substations and accumulators
            -- But, needs to be rotatable without issues.
            {
                production_type = "input",        
                base_area = 10,
                base_level = -1,
                height = 2,
                pipe_connections = {
                    {type = "input", position = {-1.5, 0.5}, max_underground_distance = 3},
                    {type = "input", position = {-1.5, -0.5}, max_underground_distance = 3},
                },        
            },
            {
                production_type = "output",        
                base_area = 1,
                base_level = 1,
                pipe_connections = {
                    {type = "output", position = {1.5, 0.5}, max_underground_distance = 3},        
                    {type = "output", position = {1.5, -0.5}, max_underground_distance = 3},
                },        
            },
        },        
        animation =
        {
            layers =
            {
                {
                    filename = "__FluidicPower__/graphics/entities/transformers/transformer-antenna-shadow.png",
                    width = 63,
                    height = 49,
                    line_length = 8,
                    frame_count = 32,
                    shift = { 2.015, 0.34},
                    animation_speed = 2,
                    scale = 0.6
                },
                {
                    filename = "__FluidicPower__/graphics/entities/transformers/transformer-base-sheet.png",
                    width = 116,
                    height = 93,
                    frame_count = 32,
                    line_length = 8,
                    frame_count = 32,
                    shift = { 0.23, 0.046875},
                    scale = 0.66
                },                
                {
                    filename = "__FluidicPower__/graphics/entities/transformers/transformer-antenna.png",
                    width = 54,
                    height = 50,
                    line_length = 8,
                    frame_count = 32,
                    shift = { 0, -1.2},
                    animation_speed = 2,
                    scale = 0.8
                },                
            }
        },
    }
}})