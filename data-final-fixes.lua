Generator = require("prototypes.fluidic-pole-generator")

-- Create K2's bigger substation
-------------------------------------------------------
-- if mods["Krastorio2"] then



--     data:extend({   
--         {
--             type = "recipe",
--             name = "fluidic-10-kilojoules-generate-k2-substation-mk2",
--             icon_size = 64,
--             icon = "__FluidicPower__/graphics/icons/fluidic-level-1-generate-icon.png",
--             category = "fluidic-generate",
--             subgroup = "energy-pipe-distribution",
--             order = "a[kilojoules]-a[kilojoules]",        
--             ingredients ={},
--             energy_required = 0.2,
--             results={{type="fluid", name="fluidic-10-kilojoules", amount=4000}},
--             hidden = true  
--         }
--     })

--     Generator.create_in_out_variant{
--         base_name = "kr-substation-mk2",
--         fluid_usage_per_tick = 166.66666666, -- P = 100MW
--         wire_reach = 26, -- K2 is 24.25
--         size = 2,   -- This is a 2x2 entity
--         in_fixed_recipe = "fluidic-10-kilojoules-generate-k2-substation-mk2",
--         energy_usage = "200MW",  -- Needs to correspond with recipe
--         size = 2,   -- This is a 2x2 entity
--     }
-- end