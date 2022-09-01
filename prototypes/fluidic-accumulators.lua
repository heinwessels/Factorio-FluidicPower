
Generator = require("prototypes.fluidic-accumulator-generator")

-- Vanilla item has special sprites and a window
local accu = Generator.create_accumulator{base_name = "accumulator"}
accu.window_bounding_box = {{-0.2, 0.3}, {-0.4, 0.7}}
accu.pictures.picture.layers[1].filename = "__FluidicPower__/graphics/entities/accumulator/accumulator.png"
accu.pictures.picture.layers[1].hr_version.filename = "__FluidicPower__/graphics/entities/accumulator/hr-accumulator.png"

if mods["Krastorio2"] then
    local accu = Generator.create_accumulator{base_name = "kr-energy-storage"}
end