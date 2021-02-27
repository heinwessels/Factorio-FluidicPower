util = require("util")
fluidic_utils = require("scripts.fluidic-utils")

-- Here I create small, medium, big and substation pole variants

function calculate_wire_reach(original)
    -- The pole wire reach will be used as the fluid entity's
    -- underground maximum distance. Since we cannot place
    -- fluid poles diagonal we will buff it.
    return math.floor(original * 1.4)
end

function create_in_variant(base_name, name)
    -- This will create the item, recipe, and entity
    -- in the fluidic IN variant with corresponding 
    -- electrics

    -- e.g.
    --      base_name = "small-electric-pole"
    --      name =      "fluidic-small-pole"

    name_in = name.."-in"
    name_electric = name_in.."-electric"

    -- How far should we make the "underground pipes"
    wire_reach = calculate_wire_reach(
        data.raw["electric-pole"][base_name].maximum_wire_distance
    )

    -- ITEM
    data:extend({
        util.merge{
            data.raw["item"][base_name],
            {
                name = name_in, 
                place_result = name_in,
            }
        },
        util.merge{
            data.raw["item"][base_name],
            {
                name = name_electric, 
                place_result = name_electric,
            }
        },
    })

    -- RECIPE
    data:extend({util.merge{
        data.raw["recipe"][base_name],
        {
            name = name_in, 
            result = name_in,
        }
    }})

    -- ENTITY
    data:extend({util.merge{
        data.raw["electric-pole"][base_name],
        {
            type = "assembling-machine",
            name = name_in,
            minable = {result = name_in},
            next_upgrade = nil,
            crafting_speed = 1,
            energy_usage = "1W",   -- Default maximum power input
            module_specification = nil,
            allowed_effects = {},
            module_specification = { module_slots = 0 },
            energy_source = {
                type = "electric",
                input_priority = "secondary",
                usage_priority = "tertiary",
                drain = "0kW"  
            },
            maximum_wire_distance = 0,
            open_sound = nil,
            close_sound = nil,            
            crafting_categories = {"fluidic-generate"},
            fluid_boxes =
            { 
              {
                production_type = "output",        
                base_area = 1,
                base_level = 1,
                pipe_connections = {
                    { type="input-output", position = {0, 1}, max_underground_distance = wire_reach},
                    { type="input-output", position = {0, -1}, max_underground_distance = wire_reach},
                    { type="input-output", position = {1, 0}, max_underground_distance = wire_reach},
                    { type="input-output", position = {-1, 0}, max_underground_distance = wire_reach}
                },
                secondary_draw_orders = { north = -1 },
              },
            },  -- Default 1x1 sized fluidbox. Won't work for substation

            -- TODO Remove these graphics
            animation = data.raw["electric-pole"][base_name].pictures,
        }
    }})

    data:extend({util.merge{
        data.raw["electric-pole"][base_name],
        {
            name = name_electric,
            minable = {result = name_electric},
            maximum_wire_distance = wire_reach  -- Make sure we can reach the extended length
        }
    }})

    -- Depending on debug option, choose which entity is exposed
    if not settings.startup["fluidic-expose-fluid-components"].value then
        -- Default
        data.raw["assembling-machine"][name_in].selection_box = {{0,0}, {0,0}}
        data.raw["assembling-machine"][name_in].drawing_box = {{0,0}, {0,0}}
    else
        -- Debug option
        data.raw["electric-pole"][name_electric].selection_box = {{0,0}, {0,0}}
        data.raw["electric-pole"][name_electric].drawing_box = {{0,0}, {0,0}}
    end
end

function create_out_variant(base_name, name)
    -- This will create the item, recipe, and entity
    -- in the fluidic OUT variant with corresponding 
    -- electrics

    -- e.g.
    --      base_name = "small-electric-pole"
    --      name =      "fluidic-small-pole"

    name_out = name.."-out"
    name_electric =name_out.."-electric"

    -- How far should we make the "underground pipes"
    wire_reach = calculate_wire_reach(
        data.raw["electric-pole"][base_name].maximum_wire_distance
    )

    -- ITEM
    data:extend({
        util.merge{
            data.raw["item"][base_name],
            {
                name = name_out, 
                place_result = name_out,
            }
        },
        util.merge{
            data.raw["item"][base_name],
            {
                name = name_electric, 
                place_result = name_electric,
            }
        },
    })

    -- RECIPE
    data:extend({util.merge{
        data.raw["recipe"][base_name],
        {
            name = name_out, 
            result = name_out,
        }
    }})

    -- ENTITY
    data:extend({util.merge{
        data.raw["electric-pole"][base_name],
        {
            type = "generator",
            name = name_out,
            minable = {result = name_out},
            effectivity = 1,
            maximum_temperature = 15,
            fluid_usage_per_tick = 1,  -- Default energy output. value = P / 60
            flow_length_in_ticks = 360,
            burns_fluid = true,
            two_direction_only = true,                        
            fluid_box =
            {
                base_area = 1,            
                pipe_connections =
                {
                    {type = "input-output", position = {-1, 0}, max_underground_distance = wire_reach},
                    {type = "input-output", position = {1, 0}, max_underground_distance = wire_reach},
                    {type = "input-output", position = {0, -1}, max_underground_distance = wire_reach},
                    {type = "input-output", position = {0, 1}, max_underground_distance = wire_reach},
                },
                production_type = "input-output",
                minimum_temperature = 10,
                filter = "fluidic-10-kilojoules"
            },  -- Default 1x1 sized fluidbox. Won't work for substation
            energy_source =
            {
                type = "electric",
                usage_priority = "tertiary"
            },

            -- TODO Remove these
            vertical_animation = data.raw["electric-pole"][base_name].pictures,
            horizontal_animation = data.raw["electric-pole"][base_name].pictures,
        }
    }})
    data:extend({util.merge{
        data.raw["electric-pole"][base_name],
        {
            name = name_electric,
            minable = {result = name_electric},
            maximum_wire_distance = wire_reach  -- Make sure we can reach the extended length
        }
    }})

    -- Depending on debug option, choose which entity is exposed
    if not settings.startup["fluidic-expose-fluid-components"].value then
        -- Default
        data.raw["generator"][name_out].selection_box = {{0,0}, {0,0}}
        data.raw["generator"][name_out].drawing_box = {{0,0}, {0,0}}
    else
        -- Debug option
        data.raw["electric-pole"][name_electric].selection_box = {{0,0}, {0,0}}
        data.raw["electric-pole"][name_electric].drawing_box = {{0,0}, {0,0}}
    end
end

function create_transmit_variant(base_name, name)
    -- This will create the item, recipe, and entity
    -- in for a fluidic entity that can only transmit
    -- power. Currently this is only used for big poles

    -- e.g.
    --      base_name = "small-electric-pole"
    --      name =      "fluidic-small-pole"
    
    name_electric =name.."-electric"

    -- How far should we make the "underground pipes"
    wire_reach = calculate_wire_reach(
        data.raw["electric-pole"][base_name].maximum_wire_distance
    )

    -- ITEM
    data:extend({
        util.merge{
            data.raw["item"][base_name],
            {
                name = name, 
                place_result = name,
            }
        },
        util.merge{
            data.raw["item"][base_name],
            {
                name = name_electric, 
                place_result = name_electric,
            }
        },
    })

    -- RECIPE    
    data:extend({util.merge{
        data.raw["recipe"][base_name],
        {
            name = name, 
            result = name,
        }
    }})
    
    -- ENTITY
    data:extend({util.merge{
        data.raw["electric-pole"][base_name],
        {
            type = "pipe",
            name = name,
            minable = {result = name},
            horizontal_window_bounding_box = {{0,0},{0,0}},
            vertical_window_bounding_box = {{0,0},{0,0}},
            fluid_box =
            {     
                height = 2,
                pipe_connections =
                {
                    {type = "input-output", position = {-1.5, 0.5}, max_underground_distance = wire_reach},        
                    {type = "input-output", position = {-1.5, -0.5}, max_underground_distance = wire_reach},
                    {type = "input-output", position = {1.5, 0.5}, max_underground_distance = wire_reach},
                    {type = "input-output", position = {1.5, -0.5}, max_underground_distance = wire_reach},

                    {type = "input-output", position = { 0.5, -1.5,}, max_underground_distance = wire_reach},        
                    {type = "input-output", position = {-0.5, -1.5}, max_underground_distance = wire_reach},
                    {type = "input-output", position = { 0.5, 1.5}, max_underground_distance = wire_reach},
                    {type = "input-output", position = {-0.5, 1.5}, max_underground_distance = wire_reach},
                },
            },
            pictures = {
                straight_vertical_single = data.raw["electric-pole"][base_name].pictures,
                straight_vertical = data.raw["electric-pole"][base_name].pictures,
                straight_vertical_window = data.raw["electric-pole"][base_name].pictures,
                straight_horizontal = data.raw["electric-pole"][base_name].pictures,
                straight_horizontal_window = data.raw["electric-pole"][base_name].pictures,
                straight_horizontal_single = data.raw["electric-pole"][base_name].pictures,
                corner_up_right = data.raw["electric-pole"][base_name].pictures,
                corner_up_left = data.raw["electric-pole"][base_name].pictures,
                corner_down_right = data.raw["electric-pole"][base_name].pictures,
                corner_down_left = data.raw["electric-pole"][base_name].pictures,
                t_up = data.raw["electric-pole"][base_name].pictures,
                t_down = data.raw["electric-pole"][base_name].pictures,
                t_left = data.raw["electric-pole"][base_name].pictures,
                t_right = data.raw["electric-pole"][base_name].pictures,
                cross = data.raw["electric-pole"][base_name].pictures,
                ending_up = data.raw["electric-pole"][base_name].pictures,
                ending_down = data.raw["electric-pole"][base_name].pictures,
                ending_left = data.raw["electric-pole"][base_name].pictures,
                ending_right = data.raw["electric-pole"][base_name].pictures,
                horizontal_window_background = data.raw["electric-pole"][base_name].pictures,
                vertical_window_background = data.raw["electric-pole"][base_name].pictures,
                fluid_background = data.raw["electric-pole"][base_name].pictures,
                low_temperature_flow = data.raw["electric-pole"][base_name].pictures,
                middle_temperature_flow = data.raw["electric-pole"][base_name].pictures,
                high_temperature_flow = data.raw["electric-pole"][base_name].pictures,
                gas_flow = data.raw["electric-pole"][base_name].pictures,
            }
        }
    }})
    data:extend({util.merge{
        data.raw["electric-pole"][base_name],
        {
            name = name_electric,
            minable = {result = name_electric},
            supply_area_distance = 0,
            maximum_wire_distance = wire_reach  -- Make sure we can reach the extended length
        }
    }})

    -- Depending on debug option, choose which entity is exposed
    if not settings.startup["fluidic-expose-fluid-components"].value then
        -- Default
        data.raw["pipe"][name].selection_box = {{0,0}, {0,0}}
        data.raw["pipe"][name].drawing_box = {{0,0}, {0,0}}
    else
        -- Debug option
        data.raw["electric-pole"][name_electric].selection_box = {{0,0}, {0,0}}
        data.raw["electric-pole"][name_electric].drawing_box = {{0,0}, {0,0}}
    end
end

---------------------------------------------------
-- HERE I ACTUALLY CREATE THE PROTOTYPES
---------------------------------------------------

-- Formula to calculate fluid usage per tick
--      P = Maximum power usage
--      u = energy of single unit in Joule    
--      s = fluid usage per tick
-- Then:
--      P = u * s * 60

-- Create small poles
create_in_variant("small-electric-pole", "fluidic-small-pole")
create_out_variant("small-electric-pole", "fluidic-small-pole")
data.raw["generator"]["fluidic-small-pole-out"].fluid_usage_per_tick = 9 -- P = 5MW
data.raw["assembling-machine"]["fluidic-small-pole-in"].energy_usage = "5MW"
data.raw["assembling-machine"]["fluidic-small-pole-in"].fixed_recipe = "fluidic-10-kilojoules-generate-small"

-- Create Medium poles
create_in_variant("medium-electric-pole", "fluidic-medium-pole")
create_out_variant("medium-electric-pole", "fluidic-medium-pole")
data.raw["generator"]["fluidic-medium-pole-out"].fluid_usage_per_tick = 50 -- P = 30MW
data.raw["assembling-machine"]["fluidic-medium-pole-in"].energy_usage = "30MW"
data.raw["assembling-machine"]["fluidic-medium-pole-in"].fixed_recipe = "fluidic-10-kilojoules-generate-medium"

-- Create substations
create_in_variant("substation", "fluidic-substation")
create_out_variant("substation", "fluidic-substation")
data.raw["generator"]["fluidic-substation-out"].fluid_usage_per_tick = 67 -- P = 40MW
data.raw["assembling-machine"]["fluidic-substation-in"].energy_usage = "40MW"
data.raw["assembling-machine"]["fluidic-substation-in"].fixed_recipe = "fluidic-10-kilojoules-generate-substation"
data.raw["generator"]["fluidic-substation-out"].fluid_box = 
{
    base_area = 1,        
    pipe_connections =
    {
        {type = "input-output", position = {-1.5, 0.5}, max_underground_distance = 10},
        {type = "input-output", position = {1.5, 0.5}, max_underground_distance = 10},
        {type = "input-output", position = {-0.5, 1.5}, max_underground_distance = 10},
        {type = "input-output", position = {-0.5, -1.5}, max_underground_distance = 10},

        -- TODO Tunnel rotations through electric entity so that there can be less fluidboxes
        {type = "input-output", position = {-1.5, -0.5}, max_underground_distance = 10},
        {type = "input-output", position = {1.5, -0.5}, max_underground_distance = 10},
        {type = "input-output", position = {0.5, 1.5}, max_underground_distance = 10},
        {type = "input-output", position = {0.5, -1.5}, max_underground_distance = 10},
    },
    production_type = "input-output",        
    minimum_temperature = 10,
    filter = "fluidic-10-kilojoules"
}
data.raw["assembling-machine"]["fluidic-substation-in"].fluid_boxes = { 
    {
        production_type = "output",        
        base_area = 1,
        base_level = 1,
        pipe_connections = {
            {type = "output", position = {-1.5, 0.5}, max_underground_distance = 10},
            {type = "output", position = {1.5, 0.5}, max_underground_distance = 10},
            {type = "output", position = {-0.5, 1.5}, max_underground_distance = 10},
            {type = "output", position = {-0.5, -1.5}, max_underground_distance = 10},

            -- TODO Tunnel rotations through electric entity so that there can be less fluidboxes
            {type = "output", position = {-1.5, -0.5}, max_underground_distance = 10},
            {type = "output", position = {1.5, -0.5}, max_underground_distance = 10},
            {type = "output", position = {0.5, 1.5}, max_underground_distance = 10},
            {type = "output", position = {0.5, -1.5}, max_underground_distance = 10},
        },
        secondary_draw_orders = { north = -1 },
        filter = "fluidic-10-kilojoules"
    },
}

-- Create big pole
create_transmit_variant("big-electric-pole", "fluidic-big-pole")


-- Finally hide the vanilla ones
data.raw["recipe"]["small-electric-pole"].enabled = false
data.raw["recipe"]["medium-electric-pole"].enabled = false
data.raw["recipe"]["big-electric-pole"].enabled = false
data.raw["recipe"]["substation"].enabled = false
