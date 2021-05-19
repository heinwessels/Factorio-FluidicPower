util = require("util")
constants = require("constants")
fluidic_utils = require("scripts.fluidic-utils")
Generator = require("prototypes.fluidic-pole-generator")


-- Formula to calculate fluid usage per tick
--      P = Maximum power usage
--      u = energy of single unit in Joule    
--      s = fluid usage per tick
-- Then:
--      P = u * s * 60

-- Create small poles
-------------------------------------------------------
local small_wire_reach = 10  -- (vanilla is 7.5)
Generator.create_in_variant{
    base_name = "small-electric-pole",
    fixed_recipe = "fluidic-10-kilojoules-generate-small",
    energy_usage = "5MW",
    next_upgrade = "fluidic-medium-electric-pole-in-place",
    fluid_box_base_area = 0.5,
    wire_reach = small_wire_reach,
}
Generator.create_out_variant{
    base_name = "small-electric-pole",
    fluid_usage_per_tick = 8.333333, -- P = 5MW
    fluid_box_base_area = 0.5,
    wire_reach = small_wire_reach,
    next_upgrade = "fluidic-medium-electric-pole-out-place",
}

-- Create Medium poles
-------------------------------------------------------
local medium_wire_reach = 12 -- (Vanilla is 9)
Generator.create_in_variant{
    base_name = "medium-electric-pole",
    fixed_recipe = "fluidic-10-kilojoules-generate-medium",
    energy_usage = "30MW",
    wire_reach = medium_wire_reach,
}
Generator.create_out_variant{
    base_name = "medium-electric-pole",
    fluid_usage_per_tick = 50, -- P = 30MW
    wire_reach = medium_wire_reach,
}

-- Create substations
-------------------------------------------------------
local substation_wire_reach = 18 -- vanilla is 18
Generator.create_in_variant{
    base_name = "substation",
    fixed_recipe = "fluidic-10-kilojoules-generate-substation",
    energy_usage = "40MW",
    wire_reach = substation_wire_reach,
    size = 2,   -- This is a 2x2 entity
}
Generator.create_out_variant{
    base_name = "substation",
    fluid_usage_per_tick = 66.66666666, -- P = 40MW
    wire_reach = substation_wire_reach,
    size = 2,   -- This is a 2x2 entity
}

-- Create big pole
-------------------------------------------------------
local big_wire_reach = 35 -- vanilla reach is 30
Generator.create_transmit_variant{
    base_name = "big-electric-pole",
    wire_reach = big_wire_reach,
    size = 2,   -- This is a 2x2 entity
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
