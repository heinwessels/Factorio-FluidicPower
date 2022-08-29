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
--
-- Remember to update recipes!

-- Create small poles
-------------------------------------------------------
local small_wire_reach = 9  -- (vanilla is 7.5)
Generator.create_in_out_variant{
    base_name = "small-electric-pole",
    fluid_usage_per_tick = 8.333333, -- P = 5MW
    fluid_box_base_area = 0.5,
    wire_reach = small_wire_reach,
    in_fixed_recipe = "fluidic-10-kilojoules-generate-small",
    energy_usage = "5MW",  -- Needs to correspond with recipe
    next_upgrade_base = "fluidic-medium-electric-pole",
    fluid_box_base_area = 0.5,
    wire_reach = small_wire_reach,
}

-- Create Medium poles
-------------------------------------------------------
local medium_wire_reach = 11 -- (Vanilla is 9)
Generator.create_in_out_variant{
    base_name = "medium-electric-pole",
    fluid_usage_per_tick = 50, -- P = 30MW
    wire_reach = medium_wire_reach,
    in_fixed_recipe = "fluidic-10-kilojoules-generate-medium",
    energy_usage = "30MW",  -- Needs to correspond with recipe
    wire_reach = medium_wire_reach,
}

-- Create substations
-------------------------------------------------------
local substation_wire_reach = 20 -- vanilla is 18
Generator.create_in_out_variant{
    base_name = "substation",
    fluid_usage_per_tick = 166.66666666, -- P = 100MW
    wire_reach = substation_wire_reach,
    size = 2,   -- This is a 2x2 entity
    in_fixed_recipe = "fluidic-10-kilojoules-generate-substation",
    energy_usage = "100MW",  -- Needs to correspond with recipe
    wire_reach = substation_wire_reach,
    size = 2,   -- This is a 2x2 entity
}

-- Create big pole
-------------------------------------------------------
local big_wire_reach = 34 -- vanilla reach is 30
Generator.create_transmit_variant{
    base_name = "big-electric-pole",
    wire_reach = big_wire_reach,
    size = 2,   -- This is a 2x2 entity
}

if mods["Krastorio2"] and data.raw.recipe["kr-substation-mk2"] then
    -- Checking for recipe first to see if the substation mk2 is 
    -- enabled. The settings dissapears in KR2 1.3.
    -- I'm making it the same as a normal substation
    Generator.create_in_out_variant{
        base_name = "kr-substation-mk2",
        fluid_usage_per_tick = 166.66666666, -- P = 100MW
        wire_reach = 26, -- K2 is 24.25
        size = 2,   -- This is a 2x2 entity
        in_fixed_recipe = "fluidic-10-kilojoules-generate-k2-substation-mk2",
        energy_usage = "100MW",  -- Needs to correspond with recipe
        size = 2,   -- This is a 2x2 entity
    }

    -- Some required extra settings
    data.raw["electric-pole"]["fluidic-substation-out-electric"].next_upgrade = "fluidic-kr-substation-mk2-out-electric"
    data.raw["electric-pole"]["fluidic-substation-in-electric"].next_upgrade = "fluidic-kr-substation-mk2-in-electric"
    data.raw["electric-pole"]["substation"].next_upgrade = nil -- The entity still exists
end
