local config = { }

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

config.poles = {
    ["small-electric-pole"] = {
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
        wire_distance_override = 9, -- vanilla is 7.5
    },
    ["medium-electric-pole"] = {
        fluid_usage_per_tick = 50, -- P = 30MW
        wire_reach = medium_wire_reach,
        in_fixed_recipe = {
            energy_required = 0.25,
            results={{type="fluid", name="fluidic-10-kilojoules", amount=750}},
        },
        energy_usage = "30MW",  -- Needs to correspond with recipe
        wire_distance_override = 11, -- vanilla is 9
    },
    ["substation"] = {
        fluid_usage_per_tick = 166.66666666, -- P = 100MW
        wire_reach = substation_wire_reach,
        size = 2,   -- This is a 2x2 entity
        in_fixed_recipe = {
            energy_required = 0.2,
            results={{type="fluid", name="fluidic-10-kilojoules", amount=2000}},
        },
        energy_usage = "100MW",  -- Needs to correspond with recipe
        size = 2,   -- This is a 2x2 entity
        wire_distance_override = 34, -- vanilla reach is 30
    },
    ["big-electric-pole"] = {
        transmit_only = true,
        size = 2,   -- This is a 2x2 entity
        wire_distance_override = 20, -- vanilla is 18
    },
    ["kr-substation-mk2"] = {
        fluid_usage_per_tick = 166.66666666, -- P = 100MW
        size = 2,   -- This is a 2x2 entity
        in_fixed_recipe = {
            energy_required = 0.2,
            results={{type="fluid", name="fluidic-10-kilojoules", amount=2000}},
        },
        energy_usage = "100MW",  -- Needs to correspond with recipe
        size = 2,   -- This is a 2x2 entity
        wire_distance_override = 26, -- K2 is 24.25
    },
    ["floating-electric-pole"] = { -- From Cargo Ships
        transmit_only = true,
        size = 2,   -- This is a 2x2 entity
        wire_distance_override = 52, -- Default is 48
    },
}

------------------
-- POST PROCESSING
------------------

-- Create lookup tables to easily jump between different pole types
config.entity_fluid_to_electric_lu = { }
config.entity_electric_to_fluid_lu = { }
config.entity_fluid_to_base_lu = { }
for pole_name, pole_config in pairs(config.poles) do
    if not pole_config.transmit_only then
        config.entity_fluid_to_electric_lu["fluidic-"..pole_name.."-in"] =
            "fluidic-"..pole_name.."-in-electric"
        config.entity_fluid_to_electric_lu["fluidic-"..pole_name.."-out"] =
            "fluidic-"..pole_name.."-out-electric"

        config.entity_electric_to_fluid_lu["fluidic-"..pole_name.."-in-electric"] =
            "fluidic-"..pole_name.."-in"
        config.entity_electric_to_fluid_lu["fluidic-"..pole_name.."-out-electric"] =
            "fluidic-"..pole_name.."-out"

        config.entity_fluid_to_base_lu["fluidic-"..pole_name.."-in-"] = pole_name
        config.entity_fluid_to_base_lu["fluidic-"..pole_name.."-out"] = pole_name
    else
        config.entity_fluid_to_electric_lu["fluidic-"..pole_name] =
            "fluidic-"..pole_name.."-electric"        
        config.entity_electric_to_fluid_lu["fluidic-"..pole_name.."-electric"] =
            "fluidic-"..pole_name
        config.entity_fluid_to_base_lu["fluidic-"..pole_name] = pole_name
    end
end


return config