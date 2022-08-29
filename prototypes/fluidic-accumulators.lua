
Generator = require("prototypes.fluidic-accumulator-generator")

local accu = Generator.create_accumulator{
    base_name = "accumulator"
}
-- Vanilla item has special sprites
accu.pictures.picture.layers[1].filename = "__FluidicPower__/graphics/entities/accumulator/accumulator.png"
accu.pictures.picture.layers[1].hr_version.filename = "__FluidicPower__/graphics/entities/accumulator/hr-accumulator.png"