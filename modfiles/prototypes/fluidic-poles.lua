util = require("util")

-- Here I create small, medium, big and substation pole variants

function create_in_variant(base_name, name)
    -- This will create the item, recipe, and entity
    -- in the fluidic IN variant with corresponding 
    -- electrics

    -- e.g.
    --      base_name = "small-electric-pole"
    --      name =      "fluidic-small-pole"

    name_in = name.."-in"
    name_electric = name_in.."-electric"

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
            selection_box = {{0,0}, {0,0}},
            drawing_box = {{0,0}, {0,0}},
            maximum_wire_distance = 0,
            open_sound = nil,
            close_sound = nil,
            fixed_recipe = "fluidic-10-kilojoules-generate-small",
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
            maximum_wire_distance = 1,
        }
    }})
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
            maximum_wire_distance = 1,
        }
    }})
end


---------------------------------------------------
-- HERE I ACTUALLY CREATE THE PROTOTYPES
---------------------------------------------------

-- Create small poles
create_in_variant("small-electric-pole", "fluidic-small-pole")
create_out_variant("small-electric-pole", "fluidic-small-pole")
data.raw["generator"]["fluidic-small-pole-out"].fluid_usage_per_tick = 84 -- x 60 = 5MW
data.raw["assembling-machine"]["fluidic-small-pole-in"].energy_usage = "5MW"

-- Create Medium poles
create_in_variant("medium-electric-pole", "fluidic-medium-pole")
create_out_variant("medium-electric-pole", "fluidic-medium-pole")
data.raw["generator"]["fluidic-medium-pole-out"].fluid_usage_per_tick = 500 -- x 60 = 30MW
data.raw["assembling-machine"]["fluidic-medium-pole-in"].energy_usage = "30MW"

-- Create substations
create_in_variant("substation", "fluidic-substation")
create_out_variant("substation", "fluidic-substation")
data.raw["generator"]["fluidic-substation-out"].fluid_usage_per_tick = 666 -- x 60 = 40MW
data.raw["assembling-machine"]["fluidic-substation-in"].energy_usage = "40MW"
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

-- Finally hide the vanilla ones
data.raw["recipe"]["small-electric-pole"].hidden = true
data.raw["recipe"]["medium-electric-pole"].hidden = true
data.raw["recipe"]["substation"].hidden = true