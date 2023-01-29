util = require("util")
fluidic_utils = require("scripts.fluidic-utils")
Generator = require("prototypes.fluidic-pole-generator")
config = require("config")

for pole_name, pole_config in pairs(config.poles) do
    local pole = data.raw["electric-pole"][pole_name]
    if not pole then goto continue end

    -- Maybe override length
    if settings.startup["fluidic-override-pole-wire-length"].value then
        if pole then pole.maximum_wire_distance = pole_config.wire_distance_override end
    end

    -- Now create the fluidic variations
    if pole_config.type == "in-out" then
        Generator.create_in_out_variant(util.merge{
            {base_name = pole_name}, pole_config 
        })
    else
        Generator.create_transmit_variant(util.merge{
            {base_name = pole_name}, pole_config 
        })
    end

    ::continue::
end


if mods["Krastorio2"] and data.raw.recipe["kr-substation-mk2"] then
    -- Some required extra settings
    data.raw["electric-pole"]["fluidic-substation-out-electric"].next_upgrade = 
            "fluidic-kr-substation-mk2-out-electric"
    data.raw["electric-pole"]["fluidic-substation-in-electric"].next_upgrade = 
            "fluidic-kr-substation-mk2-in-electric"
    data.raw["electric-pole"]["substation"].next_upgrade = nil
end
