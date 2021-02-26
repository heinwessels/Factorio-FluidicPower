util = require("util")

--------------------
-- ITEMS
--------------------
data:extend({
    util.merge{
        data.raw["item"]["medium-electric-pole"],
        {
            name = "fluidic-medium-pole-in", 
            place_result = "fluidic-medium-pole-in",
        }
    },
    util.merge{
        data.raw["item"]["medium-electric-pole"],
        {
            name = "fluidic-medium-pole-out", 
            place_result = "fluidic-medium-pole-out",
        }
    },
    util.merge{
        data.raw["item"]["medium-electric-pole"],
        {
            name = "fluidic-medium-pole-in-electric", 
            place_result = "fluidic-medium-pole-in-electric",
            hidden = true
        }
    },
    util.merge{
        data.raw["item"]["medium-electric-pole"],
        {
            name = "fluidic-medium-pole-out-electric", 
            place_result = "fluidic-medium-pole-out-electric",
            hidden = true
        }
    },
})

--------------------
-- RECIPES
--------------------
data:extend({
    util.merge{
        data.raw["recipe"]["medium-electric-pole"],
        {
            name = "fluidic-medium-pole-in", 
            result = "fluidic-medium-pole-in",
        }
    },
    util.merge{
        data.raw["recipe"]["medium-electric-pole"],
        {
            name = "fluidic-medium-pole-out", 
            result = "fluidic-medium-pole-out",
        }
    },
})

-- Now hide the vanilla recipe
data.raw["recipe"]["medium-electric-pole"].hidden = true

--------------------
-- ENTITIES
--------------------
data:extend({util.merge{
    data.raw["electric-pole"]["medium-electric-pole"],
    {
        type = "generator",
        name = "fluidic-medium-pole-out",
        minable = {result = "fluidic-medium-pole-out"},
        effectivity = 1,
        maximum_temperature = 15,
        fluid_usage_per_tick = 500,  -- Power output. P / 60
        flow_length_in_ticks = 360,
        burns_fluid = true,
        two_direction_only = true,
        selection_box = {{0,0}, {0,0}},
        drawing_box = {{0,0}, {0,0}},
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
        vertical_animation = data.raw["electric-pole"]["medium-electric-pole"].pictures,
        horizontal_animation = data.raw["electric-pole"]["medium-electric-pole"].pictures,
    }
}})

data:extend({util.merge{
    data.raw["electric-pole"]["medium-electric-pole"],
    {
        type = "assembling-machine",
        name = "fluidic-medium-pole-in",
        minable = {result = "fluidic-medium-pole-in"},
        next_upgrade = nil,
        crafting_speed = 1,
        energy_usage = "30MW",   -- This is essentially the maximum power into the pole
        module_specification = nil,
        allowed_effects = {},
        module_specification = { module_slots = 0 },
        energy_source = {
            type = "electric",
            input_priority = "secondary",
            usage_priority = "tertiary",
            drain = "0kW"  
        },        
        selection_box = {{0,0}, {0,0}},
        drawing_box = {{0,0}, {0,0}},
        maximum_wire_distance = 0,
        open_sound = nil,
        close_sound = nil,
        fixed_recipe = "fluidic-10-kilojoules-generate-medium",
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
        animation = data.raw["electric-pole"]["medium-electric-pole"].pictures,
    }
}})

data:extend({util.merge{
    data.raw["electric-pole"]["medium-electric-pole"],
    {
        name = "fluidic-medium-pole-in-electric",
        minable = {result = "fluidic-medium-pole-in"},   
        maximum_wire_distance = 1,
    }
}})

data:extend({util.merge{
    data.raw["electric-pole"]["medium-electric-pole"],
    {
        name = "fluidic-medium-pole-out-electric",
        minable = {result = "fluidic-medium-pole-out"},   
        maximum_wire_distance = 1,
    }
}})

