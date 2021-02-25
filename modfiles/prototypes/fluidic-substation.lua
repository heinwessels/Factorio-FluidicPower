util = require("util")

--------------------
-- ITEMS
--------------------
data:extend({
    util.merge{
        data.raw["item"]["substation"],
        {
            name = "fluidic-substation-in", 
            place_result = "fluidic-substation-in",
        }
    },
    util.merge{
        data.raw["item"]["substation"],
        {
            name = "fluidic-substation-out", 
            place_result = "fluidic-substation-out",
        }
    },
    util.merge{
        data.raw["item"]["substation"],
        {
            name = "fluidic-substation-in-electric", 
            place_result = "fluidic-substation-in-electric",
            hidden = true
        }
    },
    util.merge{
        data.raw["item"]["substation"],
        {
            name = "fluidic-substation-out-electric", 
            place_result = "fluidic-substation-out-electric",
            hidden = true
        }
    },
})

--------------------
-- RECIPES
--------------------
data:extend({
    util.merge{
        data.raw["recipe"]["substation"],
        {
            name = "fluidic-substation-in", 
            result = "fluidic-substation-in",
        }
    },
    util.merge{
        data.raw["recipe"]["substation"],
        {
            name = "fluidic-substation-out", 
            result = "fluidic-substation-out",
        }
    },
})

-- Now hide the vanilla recipe
data.raw["recipe"]["substation"].hidden = true

--------------------
-- ENTITIES
--------------------
data:extend({util.merge{
    data.raw["electric-pole"]["substation"],
    {
        type = "generator",
        name = "fluidic-substation-out",
        minable = {result = "fluidic-substation-out"},
        effectivity = 1,
        maximum_temperature = 15,
        fluid_usage_per_tick = 1,
        flow_length_in_ticks = 360,
        burns_fluid = true,
        two_direction_only = true,
        selection_box = {{0,0}, {0,0}},
        drawing_box = {{0,0}, {0,0}},
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
            filter = "fluidic-10-kilojoules"
        },
        energy_source =
        {
            type = "electric",
            usage_priority = "tertiary"
        },
        vertical_animation = data.raw["electric-pole"]["substation"].pictures,
        horizontal_animation = data.raw["electric-pole"]["substation"].pictures,
    }
}})

data:extend({util.merge{
    data.raw["electric-pole"]["substation"],
    {
        type = "assembling-machine",
        name = "fluidic-substation-in",
        minable = {result = "fluidic-substation-in"},
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
        selection_box = {{0,0}, {0,0}},
        drawing_box = {{0,0}, {0,0}},
        maximum_wire_distance = 0,
        open_sound = nil,
        close_sound = nil,
        fixed_recipe = "fluidic-10-kilojoules-generate",
        crafting_categories = {"fluidic-generate"},
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
                filter = "fluidic-10-kilojoules"
            },
        },
        animation = data.raw["electric-pole"]["substation"].pictures,
    }
}})

data:extend({util.merge{
    data.raw["electric-pole"]["substation"],
    {
        name = "fluidic-substation-in-electric",
        minable = {result = "fluidic-substation-in"},   
        maximum_wire_distance = 1,
    }
}})

data:extend({util.merge{
    data.raw["electric-pole"]["substation"],
    {
        name = "fluidic-substation-out-electric",
        minable = {result = "fluidic-substation-out"},   
        maximum_wire_distance = 1,
    }
}})