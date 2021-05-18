util = require("util")
constants = require("constants")
fluidic_utils = require("scripts.fluidic-utils")
Generator = require("prototypes.fluidic-pole-generator")

function calculate_wire_reach(original)
    -- The pole wire reach will be used as the fluid entity's
    -- underground maximum distance. Since we cannot place
    -- fluid poles diagonal we will buff it.
    return math.floor(original * 1.4)
end


-- Formula to calculate fluid usage per tick
--      P = Maximum power usage
--      u = energy of single unit in Joule    
--      s = fluid usage per tick
-- Then:
--      P = u * s * 60

-- Create small poles
local wire_reach = 10
Generator.create_in_variant{
    base_name = "small-electric-pole",
    fixed_recipe = "fluidic-10-kilojoules-generate-small",
    energy_usage = "5MW",
    next_upgrade = "fluidic-medium-electric-pole-in-place",
    fluid_box_base_area = 0.5,
    wire_reach = wire_reach,
}
Generator.create_out_variant{
    base_name = "small-electric-pole",
    fluid_usage_per_tick = 8.333333, -- P = 5MW
    fluid_box_base_area = 0.5,
    wire_reach = wire_reach,
    next_upgrade = "fluidic-medium-electric-pole-out-place",
}

-- Create Medium poles
wire_reach = 12
Generator.create_in_variant{
    base_name = "medium-electric-pole",
    fixed_recipe = "fluidic-10-kilojoules-generate-medium",
    energy_usage = "30MW",
    wire_reach = wire_reach,
}
Generator.create_out_variant{
    base_name = "medium-electric-pole",
    fluid_usage_per_tick = 50, -- P = 30MW
    wire_reach = wire_reach,
}

-- Create substations
wire_reach = 18
Generator.create_in_variant{
    base_name = "substation",
    fixed_recipe = "fluidic-10-kilojoules-generate-substation",
    energy_usage = "40MW",
    wire_reach = wire_reach,
}
Generator.create_out_variant{
    base_name = "substation",
    fluid_usage_per_tick = 66.66666666, -- P = 40MW
    wire_reach = wire_reach,
}
for _, machine in pairs{"fluidic-substation-in", "fluidic-substation-in-place"} do    
    data.raw["assembling-machine"][machine].fluid_boxes = { 
        {
            production_type = "output",        
            base_area = 1,
            base_level = 1,
            pipe_connections = {               
                {type = "output", position = {-1.5, -0.5}, max_underground_distance = wire_reach},
                {type = "output", position = {1.5,  -0.5}, max_underground_distance = wire_reach},
                {type = "output", position = {-0.5, -1.5}, max_underground_distance = wire_reach},
                {type = "output", position = { -0.5, 1.5}, max_underground_distance = wire_reach},

                -- These connections are only for energy sensors.
                -- Will not connect to other poles (unless placed directly adjacent)
                -- and thus not influence fluid flow
                {type = "output", position = {-1.5, 0.5}, max_underground_distance = 1},
                {type = "output", position = {1.5, 0.5}, max_underground_distance = 1},
                {type = "output", position = {0.5, -1.5,}, max_underground_distance = 1},
                {type = "output", position = {0.5, 1.5}, max_underground_distance = 1},
            },
            secondary_draw_orders = { north = -1 },
            filter = "fluidic-10-kilojoules"
        },
    }
end
for _, generator in pairs{"fluidic-substation-out", "fluidic-substation-out-place"} do    
    data.raw["generator"][generator].fluid_box = 
    {
        base_area = 1,
        pipe_connections =
        {
            {type = "input-output", position = {-1.5, -0.5}, max_underground_distance = wire_reach},
            {type = "input-output", position = {1.5,  -0.5}, max_underground_distance = wire_reach},
            {type = "input-output", position = {-0.5, -1.5}, max_underground_distance = wire_reach},
            {type = "input-output", position = { -0.5, 1.5}, max_underground_distance = wire_reach},

            -- These connections are only for energy sensors.
            -- Will not connect to other poles (unless placed directly adjacent)
            -- and thus not influence fluid flow
            {type = "input-output", position = {-1.5, 0.5}, max_underground_distance = 1},
            {type = "input-output", position = {1.5, 0.5}, max_underground_distance = 1},
            {type = "input-output", position = {0.5, -1.5,}, max_underground_distance = 1},
            {type = "input-output", position = {0.5, 1.5}, max_underground_distance = 1},
        },
        production_type = "input-output",        
        minimum_temperature = 10,
        filter = "fluidic-10-kilojoules"
    }
end


-- Create big pole
wire_reach = 35
Generator.create_transmit_variant{
    base_name = "big-electric-pole",
    wire_reach = wire_reach,
}

-- Finally hide the vanilla poles
for _, recipe in pairs{
    data.raw["recipe"]["small-electric-pole"],
    data.raw["recipe"]["medium-electric-pole"],
    data.raw["recipe"]["big-electric-pole"],
    data.raw["recipe"]["substation"]
} do
    recipe.enabled = false
    recipe.hidden = true
end

for _, item in pairs{
    data.raw["item"]["small-electric-pole"],
    data.raw["item"]["medium-electric-pole"],
    data.raw["item"]["big-electric-pole"],
    data.raw["item"]["substation"]
} do
    item.flags = {"hidden"}
end
