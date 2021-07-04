fluidic_utils = require("scripts.fluidic-utils")

data.raw.technology["electric-energy-distribution-1"].effects = {
    {
        type = "unlock-recipe",
        recipe = "fluidic-medium-electric-pole-in"
    },
    {
        type = "unlock-recipe",
        recipe = "medium-electric-pole"
    },
    {
        type = "unlock-recipe",
        recipe = "big-electric-pole"
    },
    {
        type = "unlock-recipe",
        recipe = "fluidic-transformer"
    },
}
data.raw.technology["electric-energy-distribution-2"].effects = {
    {
        type = "unlock-recipe",
        recipe = "fluidic-substation-in"
    },
    {
        type = "unlock-recipe",
        recipe = "substation"
    }
}

table.insert(
    data.raw.technology["circuit-network"].effects,
    {
        type = "unlock-recipe",
        recipe = "fluidic-energy-sensor"
    }
)

fluidic_utils.overwrite_technology_for_recipe(
    "power-switch", "fluidic-power-switch"
)