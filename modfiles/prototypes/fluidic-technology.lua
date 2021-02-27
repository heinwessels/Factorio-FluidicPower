fluidic_utils = require("scripts.fluidic-utils")

data.raw.technology["electric-energy-distribution-1"].effects = {
    {
        type = "unlock-recipe",
        recipe = "fluidic-medium-pole-in"
    },
    {
        type = "unlock-recipe",
        recipe = "fluidic-medium-pole-in"
    },
    {
        type = "unlock-recipe",
        recipe = "fluidic-big-pole"
    },
    {
        type = "unlock-recipe",
        recipe = "fluidic-transformer-step-up"
    },
    {
        type = "unlock-recipe",
        recipe = "fluidic-transformer-step-down"
    }
}
data.raw.technology["electric-energy-distribution-2"].effects = {
    {
        type = "unlock-recipe",
        recipe = "fluidic-substation-in"
    },
    {
        type = "unlock-recipe",
        recipe = "fluidic-substation-in"
    },
    {
        type = "unlock-recipe",
        recipe = "fluidic-energy-meter"
    },
}

fluidic_utils.overwrite_technology_for_recipe(
    "accumulator", "fluidic-accumulator"
)
fluidic_utils.overwrite_technology_for_recipe(
    "power-switch", "fluidic-power-switch"
)