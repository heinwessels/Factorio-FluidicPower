util = require("util")
constants = require("constants")
fluidic_utils = require("scripts.fluidic-utils")
Generator = require("prototypes.fluidic-pole-generator")

if settings.startup["fluidic-override-pole-wire-length"].value then
    local override_pole_wire_distance = {
        ["small-electric-pole"] = 9, -- vanilla is 7.5
        ["medium-electric-pole"] = 11, -- vanilla is 9
        ["big-electric-pole"] = 34, -- vanilla reach is 30
        ["substation"] = 20, -- vanilla is 18
        ["kr-substation-mk2"] = 26, -- K2 is 24.25
    }

    for pole_name, new_wire_distance in pairs(override_pole_wire_distance) do
        local pole = data.raw["electric-pole"][pole_name]
        if pole then pole.maximum_wire_distance = new_wire_distance end
    end
end

-- Formula to calculate fluid usage per tick
--      P = Maximum power usage
--      u = energy of single unit in Joule    
--      s = fluid usage per tick
-- Then:
--      P = u * s * 60

-- Here is a formula to show the correlation between
-- the recipe and the requried assembler energy usage
--      P = Assembler power usage in Watt
--      i = energy of input unit in Joule        
--      n = Amount of units produced per craft
--      t = Time required per craft
-- Then:
--      P = ( i * n ) / t

-- Create small poles
-------------------------------------------------------
Generator.create_in_out_variant{
    base_name = "small-electric-pole",
    fluid_usage_per_tick = 8.333333, -- P = 5MW
    fluid_box_base_area = 0.5,
    wire_reach = small_wire_reach,
    in_fixed_recipe = {
        energy_required = 0.5,
        results={{type="fluid", name="fluidic-10-kilojoules", amount=250}},
    },
    energy_usage = "5MW",  -- Needs to correspond with recipe
    next_upgrade_base = "fluidic-medium-electric-pole",
    fluid_box_base_area = 0.5,
}

-- Create Medium poles
-------------------------------------------------------
Generator.create_in_out_variant{
    base_name = "medium-electric-pole",
    fluid_usage_per_tick = 50, -- P = 30MW
    wire_reach = medium_wire_reach,
    in_fixed_recipe = {
        energy_required = 0.25,
        results={{type="fluid", name="fluidic-10-kilojoules", amount=750}},
    },
    energy_usage = "30MW",  -- Needs to correspond with recipe
}

-- Create substations
-------------------------------------------------------
Generator.create_in_out_variant{
    base_name = "substation",
    fluid_usage_per_tick = 166.66666666, -- P = 100MW
    wire_reach = substation_wire_reach,
    size = 2,   -- This is a 2x2 entity
    in_fixed_recipe = {
        energy_required = 0.2,
        results={{type="fluid", name="fluidic-10-kilojoules", amount=2000}},
    },
    energy_usage = "100MW",  -- Needs to correspond with recipe
    size = 2,   -- This is a 2x2 entity
}

-- Create big pole
-------------------------------------------------------
Generator.create_transmit_variant{
    base_name = "big-electric-pole",
    size = 2,   -- This is a 2x2 entity
}

if mods["Krastorio2"] and data.raw.recipe["kr-substation-mk2"] then
    -- Checking for recipe first to see if the substation mk2 is 
    -- enabled. The settings dissapears in KR2 1.3.
    -- I'm making it the same as a normal substation
    Generator.create_in_out_variant{
        base_name = "kr-substation-mk2",
        fluid_usage_per_tick = 166.66666666, -- P = 100MW
        size = 2,   -- This is a 2x2 entity
        in_fixed_recipe = {
            energy_required = 0.2,
            results={{type="fluid", name="fluidic-10-kilojoules", amount=2000}},
        },
        energy_usage = "100MW",  -- Needs to correspond with recipe
        size = 2,   -- This is a 2x2 entity
    }

    -- Some required extra settings
    data.raw["electric-pole"]["fluidic-substation-out-electric"].next_upgrade = 
            "fluidic-kr-substation-mk2-out-electric"
    data.raw["electric-pole"]["fluidic-substation-in-electric"].next_upgrade = 
            "fluidic-kr-substation-mk2-in-electric"
    data.raw["electric-pole"]["substation"].next_upgrade = nil
end
