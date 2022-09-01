
Generator = require("prototypes.fluidic-accumulator-generator")

-- Energy storage will remain the same, which means
-- Energy Storage = base_area x fluid_unit x 100 = 5000 kJ
-- So basically it's the contents of 5 poles in a 2x2 area.
-- Not very efficient, but how vanilla works.

-- Vanilla item has special sprites and a window
local accu = Generator.create_accumulator{base_name = "accumulator"}
accu.window_bounding_box = {{-0.2, 0.3}, {-0.4, 0.7}}
accu.pictures.picture.layers[1].filename = "__FluidicPower__/graphics/entities/accumulator/accumulator.png"
accu.pictures.picture.layers[1].hr_version.filename = "__FluidicPower__/graphics/entities/accumulator/hr-accumulator.png"


if mods["Krastorio2"] then
    local accu = Generator.create_accumulator{base_name = "kr-energy-storage"}
end