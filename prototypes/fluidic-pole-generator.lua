util = require("util")
constants = require("constants")
fluidic_utils = require("scripts.fluidic-utils")

local Generator = { }

------------------------------------------------------------------------------------------------------
-- In and Out Variant
-- (In = Source / Out = Normal)
------------------------------------------------------------------------------------------------------
function Generator.create_in_out_variant(config)

    local name = "fluidic-"..config.base_name

    local tint_in = { a = 0.75,  b = 0, g = 1.0, r = 1.0 }
    if not config.size then config.size = 1 end

    -- Items
    -----------------------------------
    -- The out pole will use the normal item
    -- The in pole will use a new item
    local item_out = data.raw["item"][config.base_name]
    item_out.place_result = name.."-out-place"
    data:extend({
        {   -- Create item-in (also source)
            type = "item",
            name = name.."-in",
            localised_name = {"", {"fluidic-text.pole-in-variant", {"entity-name."..config.base_name}}},
            localised_description={"", {"fluidic-text.pole-in-variant-description"}},
            place_result =  name.."-in-place",
            stack_size = item_out.stack_size,
            subgroup = item_out.subgroup,
            order = item_out.order,
            icons = {
                {
                    icon = data.raw["item"][config.base_name].icon,
                    tint = tint_in
                }                    
            },
            icon_size = item_out.icon_size,
            icon_mipmaps = item_out.icon_mipmaps,
        }
    })

    -- Item Recipes
    -----------------------------------
    -- The out pole will use the base recipe
    -- The in pole will be made from the out pole
    data:extend({
        {   
            type = "recipe",
            name = name.."-in",
            localised_name = {"", {"fluidic-text.pole-in-variant", {"entity-name."..config.base_name}}},
            localised_description={"", {"fluidic-text.pole-in-variant-description"}},
            ingredients = {{config.base_name, 1}},
            results = {{type = "item", name = name.."-in", amount = 1}},
            energy_required = 0.2,
        }
    })

    -- Power fluid generation recipe
    data:extend({
        util.merge{
            {
                type = "recipe",
                name = "fluidic-generate-"..config.base_name,
                icon_size = 64,
                icon = "__FluidicPower__/graphics/icons/fluidic-level-1-generate-icon.png",
                category = "fluidic-generate",
                subgroup = "energy-pipe-distribution",
                order = "a[kilojoules]-a[kilojoules]",        
                ingredients ={},
                hidden = true  
            },
            config.in_fixed_recipe
        }
    })

    -- In (source) Entities
    -----------------------------------
    do
        local pipe_offset = -math.floor(config.size / 2)
        local fluid_boxes
        if not config.size or config.size == nil or config.size == 1 then
            fluid_boxes = { 
                {
                    production_type = "output",
                    base_area = config.fluid_box_base_area or 1,
                    filter = "fluidic-10-kilojoules",
                    
                    -- Source box higher to aid pushing the fluid out just like pumps
                    -- Also, subsequent poles only fill up to about 60% if we don't increase this
                    height = 2,

                    pipe_connections = {
                        { type="input-output", position = {0, 1}, max_underground_distance = config.wire_reach + pipe_offset},
                        { type="input-output", position = {0, -1}, max_underground_distance = config.wire_reach + pipe_offset},
                        { type="input-output", position = {1, 0}, max_underground_distance = config.wire_reach + pipe_offset},
                        { type="input-output", position = {-1, 0}, max_underground_distance = config.wire_reach + pipe_offset}
                    },
                    secondary_draw_orders = { north = -1 },
                    hide_connection_info = true,
                },
            }  -- Default 1x1 sized fluidbox. Won't work for substation
        elseif config.size and config.size == 2 then
            fluid_boxes = { 
                {
                    production_type = "output",        
                    base_area = config.fluid_box_base_area or 1,
                    filter = "fluidic-10-kilojoules",
                    pipe_connections = {               
                        {type = "output", position = {-1.5, -0.5}, max_underground_distance = config.wire_reach + pipe_offset},
                        {type = "output", position = {1.5,  -0.5}, max_underground_distance = config.wire_reach + pipe_offset},
                        {type = "output", position = {-0.5, -1.5}, max_underground_distance = config.wire_reach + pipe_offset},
                        {type = "output", position = { -0.5, 1.5}, max_underground_distance = config.wire_reach + pipe_offset},
        
                        -- These connections are only for energy sensors.
                        -- Will not connect to other poles (unless placed directly adjacent)
                        -- and thus not influence fluid flow
                        {type = "output", position = {-1.5, 0.5}, max_underground_distance = 1},
                        {type = "output", position = {1.5, 0.5}, max_underground_distance = 1},
                        {type = "output", position = {0.5, -1.5,}, max_underground_distance = 1},
                        {type = "output", position = {0.5, 1.5}, max_underground_distance = 1},
                    },
                    secondary_draw_orders = { north = -1 },
                    hide_connection_info = true,
                },
            }
        else
            error("Invalid pole size specified: "..config.size)
        end

        -- First create the PLACE entity
        data:extend({util.merge{
            data.raw["electric-pole"][config.base_name],
            {
                type = "assembling-machine",
                name = name.."-in-place",
                localised_name = {"", {"fluidic-text.pole-in-variant", {"entity-name."..config.base_name}}},
                localised_description={"", {"fluidic-text.pole-in-variant-description"}},
                icons = {
                    {
                        icon = data.raw["electric-pole"][config.base_name].icon,
                        tint = tint_in
                    }                    
                },
                
                bottleneck_ignore = true,   -- For BottleNeck Lit
                
                -- This is required for when the item may not be placed due to fluids-mixing
                -- Crash in 0.6.1
                minable = {result = name.."-in"},
                
                fast_replaceable_group = "",    -- To ensure it's not a upgrade-planner option

                -- Overwrite flags so that this hidden component has barely any functionality
                -- and most imporantly not "player-creation" so that biters won't attack it
                -- but it might still happen that the entity dies and will not create the correct
                -- ghost. Therefore handle the die callback correctly.
                flags = {
                    "not-rotatable", 
                    "hide-alt-info", 
                    "placeable-neutral", 
                    "fast-replaceable-no-build-while-moving", 
                    "not-flammable",
                    "player-creation",  -- Allows to place ghosts with shift-click
                    "not-upgradable",   -- Upgrades are done through electric entity
                },          

                crafting_speed = 1,
                fixed_recipe = "fluidic-generate-"..config.base_name,
                energy_usage = config.energy_usage,
                module_specification = nil,
                allowed_effects = nil,
                module_specification = { module_slots = 0 },
                energy_source = {
                    type = "electric",
                    input_priority = "secondary",
                    usage_priority = "secondary-input",
                    drain = "0kW",
                    render_no_network_icon = false,
                    render_no_power_icon = false,
                },            
                maximum_wire_distance = 0,
                open_sound = nil,
                close_sound = nil,            
                crafting_categories = {"fluidic-generate"},
                fluid_boxes = fluid_boxes,            
                animation = data.raw["electric-pole"][config.base_name].pictures,
            }
        }})    
        data.raw["assembling-machine"][name.."-in-place"].corpse = nil -- Ensure this has no corpse
        data.raw["assembling-machine"][name.."-in-place"].next_upgrade = nil -- Upgrading done through electric item
        data.raw["assembling-machine"][name.."-in-place"].animation.layers[1].tint = tint_in
        data.raw["assembling-machine"][name.."-in-place"].animation.layers[1].hr_version.tint = tint_in

        -- Now create the main entity without graphics
        data:extend({util.merge{
            data.raw["assembling-machine"][name.."-in-place"],
            {
                name = name.."-in",
                localised_name = {"", {"fluidic-text.pole-in-variant", {"entity-name."..config.base_name}}},
                localised_description={"", {"fluidic-text.pole-in-variant-description"}},
            
                -- Allows pasting of blueprints with circuits
                -- Needs to be here with the hidden entity so that
                -- blueprints still collide correctly.
                -- Note: This breaks quick-replace, since the top entity (pole)
                -- and entity-to-place (fluidic) don't have the same collision masks.
                -- Prefer having blueprints functioning correctly.
                collision_mask = {},
            }
        }})
        data.raw["assembling-machine"][name.."-in"].animation = {
            filename = "__FluidicPower__/graphics/entities/empty.png",                
            width = 32,
            height = 32,
        }

        -- Now update create the electric entity
        data:extend({util.merge{
            data.raw["electric-pole"][config.base_name],
            {
                name = name.."-in-electric",
                localised_name = {"", {"fluidic-text.pole-in-variant", {"entity-name."..config.base_name}}},
                localised_description={"", 
                    {"fluidic-text.pole-in-variant-description"},
                    {"fluidic-text.power-rating", config.energy_usage}
                },
                icon = "__FluidicPower__/graphics/icons/"..name.."-in-icon.png",
                minable = {result = name.."-in"},
                placeable_by = {item=name.."-in",count=1}, -- This is the magic to make the pipette and blueprint work!
                maximum_wire_distance = config.wire_reach,  -- Make sure we can reach the extended length
                fast_replaceable_group = "electric-pole",   -- Reinstate the fast replaceable behaviour
                draw_copper_wires = false,                  -- Don't draw copper wires!
            }
        }})
        data.raw["electric-pole"][name.."-in-electric"].next_upgrade = 
            config.next_upgrade_base and config.next_upgrade_base.."-in-electric" or nil
        data.raw["electric-pole"][name.."-in-electric"].pictures.layers[1].tint = tint_in
        data.raw["electric-pole"][name.."-in-electric"].pictures.layers[1].hr_version.tint = tint_in

        -- Depending on debug option, choose which entity is exposed (electric[default] or fluid)
        if not constants.expose_fluid_boxes then
            -- Default fluid is not exposed
            data.raw["assembling-machine"][name.."-in"].selection_box = {{0,0}, {0,0}}
            data.raw["assembling-machine"][name.."-in"].drawing_box = {{0,0}, {0,0}}
        else
            -- Debug option
            data.raw["electric-pole"][name.."-in-electric"].selection_box = {{0,0}, {0,0}}
            data.raw["electric-pole"][name.."-in-electric"].drawing_box = {{0,0}, {0,0}}
        end
    end

    -- Out (Normal) Entities
    -----------------------------------
    do
        -- First create the entity that will be placed
        local pipe_offset = -math.floor(config.size / 2)
        local fluid_boxes
        if not config.size or config.size == nil or config.size == 1 then
            fluid_boxes = {
                base_area = config.fluid_box_base_area or 1,
                pipe_connections =
                {
                    {type = "input-output", position = {-1, 0}, max_underground_distance =config.wire_reach + pipe_offset},
                    {type = "input-output", position = {1, 0}, max_underground_distance = config.wire_reach + pipe_offset},
                    {type = "input-output", position = {0, -1}, max_underground_distance = config.wire_reach + pipe_offset},
                    {type = "input-output", position = {0, 1}, max_underground_distance = config.wire_reach + pipe_offset},
                },
                production_type = "input-output",
                minimum_temperature = 10,
                filter = "fluidic-10-kilojoules",
                hide_connection_info = true,
            }
        elseif config.size and config.size == 2 then
            fluid_boxes = {
                base_area = config.fluid_box_base_area or 1,
                pipe_connections =
                {
                    {type = "input-output", position = {-1.4, -0.5}, max_underground_distance = config.wire_reach + pipe_offset},
                    {type = "input-output", position = {1.4,  -0.5}, max_underground_distance = config.wire_reach + pipe_offset},
                    {type = "input-output", position = {-0.5, -1.4}, max_underground_distance = config.wire_reach + pipe_offset},
                    {type = "input-output", position = { -0.5, 1.4}, max_underground_distance = config.wire_reach + pipe_offset},
        
                    -- These connections are only for energy sensors.
                    -- Will not connect to other poles (unless placed directly adjacent)
                    -- and thus not influence fluid flow
                    {type = "input-output", position = {-1.4, 0.5}, max_underground_distance = 1},
                    {type = "input-output", position = {1.4, 0.5}, max_underground_distance = 1},
                    {type = "input-output", position = {0.5, -1.4,}, max_underground_distance = 1},
                    {type = "input-output", position = {0.5, 1.4}, max_underground_distance = 1},
                },
                production_type = "input-output",        
                minimum_temperature = 10,
                filter = "fluidic-10-kilojoules",
                hide_connection_info = true,
            }
        else
            error("Invalid pole size specified: "..config.size)
        end

        data:extend({util.merge{
            data.raw["electric-pole"][config.base_name],
            {
                type = "generator",
                name = name.."-out-place",
                localised_name = {"", {"fluidic-text.pole-out-variant", {"entity-name."..config.base_name}}},
                localised_description={"", {"fluidic-text.pole-out-variant-description"}},
                
                bottleneck_ignore = true,   -- For BottleNeck Lite

                -- This is required for when the item may not be placed due to fluids-mixing
                -- Crash in 0.6.1
                minable = {result = config.base_name},

                fast_replaceable_group = "",    -- To ensure it's not a upgrade-planner option

                -- Overwrite flags so that this hidden component has barely any functionality
                -- and most imporantly not "player-creation" so that biters won't attack it
                -- but it might still happen that the entity dies and will not create the correct
                -- ghost. Therefore handle the die callback correctly.
                flags = {
                    "not-rotatable", 
                    "hide-alt-info", 
                    "placeable-neutral", 
                    "fast-replaceable-no-build-while-moving", 
                    "not-flammable",
                    "player-creation",  -- Allows to place ghosts with shift-click
                    "not-upgradable",   -- Upgrades are done through electric entity
                },

                effectivity = 1,
                maximum_temperature = 15,
                fluid_usage_per_tick = config.fluid_usage_per_tick,  -- Default energy output. value = P / 60
                flow_length_in_ticks = 360,
                burns_fluid = true,
                two_direction_only = true,                        
                fluid_box = fluid_boxes,
                energy_source =
                {
                    type = "electric",
                    
                    -- This is secondary to work with the Electric Energy Interface (?)
                    -- but it creates a feedback loop when placed right next to a source
                    -- pole. This will force user to not overlap two poles at power generation.
                    usage_priority = "secondary-output" 
                },
                vertical_animation = data.raw["electric-pole"][config.base_name].pictures,
                horizontal_animation = data.raw["electric-pole"][config.base_name].pictures,
            }
        }})
        data.raw.generator[name.."-out-place"].next_upgrade = nil -- Upgrading done through electric item
        data.raw.generator[name.."-out-place"].corpse = nil -- Ensure this has no corpse

        -- Now create the main entity without graphics
        data:extend({util.merge{
            data.raw["generator"][name.."-out-place"],
            {
                name = name.."-out",
                localised_name = {"", {"fluidic-text.pole-out-variant", {"entity-name."..config.base_name}}},
                localised_description={"", {"fluidic-text.pole-out-variant-description"}},
                next_upgrade = nil,
            
                -- Allows pasting of blueprints with circuits
                -- Needs to be here with the hidden entity so that
                -- blueprints still collide correctly.
                -- Note: This breaks quick-replace, since the top entity (pole)
                -- and entity-to-place (fluidic) don't have the same collision masks.
                -- Prefer having blueprints functioning correctly.
                collision_mask = {},
            }
        }})
        data.raw["generator"][name.."-out"].vertical_animation = {
            filename = "__FluidicPower__/graphics/entities/empty.png",                
            width = 32,
            height = 32,
        }
        data.raw["generator"][name.."-out"].horizontal_animation = {
            filename = "__FluidicPower__/graphics/entities/empty.png",                
            width = 32,
            height = 32,
        }

        -- Now update create the electric entity
        data:extend({util.merge{
            data.raw["electric-pole"][config.base_name],
            {
                name = name.."-out-electric",
                localised_name = {"", {"fluidic-text.pole-out-variant", {"entity-name."..config.base_name}}},
                localised_description={"", 
                    {"fluidic-text.pole-out-variant-description"},
                    {"fluidic-text.power-rating", config.energy_usage}
                },
                minable = {result = config.base_name},
                placeable_by = {item=config.base_name,count=1}, -- This is the magic to make the pipette and blueprint work!
                maximum_wire_distance = config.wire_reach,  -- Make sure we can reach the extended length
                fast_replaceable_group = "electric-pole",   -- Reinstate the fast replaceable behaviour
                draw_copper_wires = false,                  -- Don't draw copper wires!
            }
        }})
        data.raw["electric-pole"][name.."-out-electric"].next_upgrade = 
            config.next_upgrade_base and config.next_upgrade_base.."-out-electric" or nil

        -- Depending on debug option, choose which entity is exposed
        if not constants.expose_fluid_boxes then
            -- Default
            data.raw["generator"][name.."-out"].selection_box = {{0,0}, {0,0}}        
        else
            -- Debug option
            data.raw["electric-pole"][name.."-out-electric"].selection_box = {{0,0}, {0,0}}
        end
    end

    -- Add "no-no" message to now-hidden entity
    data.raw["electric-pole"][config.base_name].localised_description = {"fluidic-text.non-accessable"}

end

------------------------------------------------------------------------------------------------------
-- TRANSMIT VARIANT
------------------------------------------------------------------------------------------------------

function Generator.create_transmit_variant(config)
    -- This will create the item, recipe, and entity
    -- in for a fluidic entity that can only transmit
    -- power. Currently this is only used for big poles

    -- e.g.
    --      base_name = "big-electric-pole"
    --      name =      "fluidic-big-electric-pole"
    
    local name = "fluidic-"..config.base_name

    if not config.size then config.size = 1 end

    -- ITEM
    data.raw["item"][config.base_name].place_result = name.."-place"
    data.raw["item"][config.base_name].localised_name = {"entity-name."..config.base_name}

    -- ENTITY
    -- First create the entity that will be used while placing    
    local pipe_offset = -math.floor(config.size / 2)
    data:extend({util.merge{
        data.raw["electric-pole"][config.base_name],
        {
            type = "pipe",
            name = name.."-place",
            localised_name = {"entity-name."..config.base_name},
            localised_description={"", {"fluidic-text.pole-transmit-variant-description"}},
            minable = {result = config.base_name},
            horizontal_window_bounding_box = {{0,0},{0,0}},
            vertical_window_bounding_box = {{0,0},{0,0}},
            bottleneck_ignore = true,   -- For BottleNeck Lite

            fast_replaceable_group = "",    -- To ensure it's not a upgrade-planner option

            -- Overwrite flags so that this hidden component has barely any functionality
            -- and most imporantly not "player-creation" so that biters won't attack it
            -- but it might still happen that the entity dies and will not create the correct
            -- ghost. Therefore handle the die callback correctly.
            flags = {
                "not-rotatable", 
                "hide-alt-info", 
                "placeable-neutral", 
                "fast-replaceable-no-build-while-moving", 
                "not-flammable",
                "player-creation",  -- Allows to place ghosts with shift-click
                "not-upgradable",   -- Upgrades are done through electric entity
            },

            fluid_box =
            {
                base_area = 1,               
                pipe_connections =
                {
                    {type = "input-output", position = {-1.5, -0.5}, max_underground_distance = config.wire_reach + pipe_offset},
                    {type = "input-output", position = {1.5, -0.5}, max_underground_distance = config.wire_reach + pipe_offset},
                    {type = "input-output", position = { -0.5, -1.5,}, max_underground_distance = config.wire_reach + pipe_offset},
                    {type = "input-output", position = { -0.5, 1.5}, max_underground_distance = config.wire_reach + pipe_offset},


                    -- These connections are only for energy sensors.
                    -- Will not connect to other poles (unless placed directly adjacent)
                    -- and thus not influence fluid flow
                    {type = "input-output", position = {-1.5, 0.5}, max_underground_distance = 1},
                    {type = "input-output", position = {1.5, 0.5}, max_underground_distance = 1},
                    {type = "input-output", position = {0.5, -1.5,}, max_underground_distance = 1},
                    {type = "input-output", position = {0.5, 1.5}, max_underground_distance = 1},
                },
                hide_connection_info = true,
            },
            pictures = {
                straight_vertical_single = data.raw["electric-pole"][config.base_name].pictures,
                straight_vertical = data.raw["electric-pole"][config.base_name].pictures,
                straight_vertical_window = data.raw["electric-pole"][config.base_name].pictures,
                straight_horizontal = data.raw["electric-pole"][config.base_name].pictures,
                straight_horizontal_window = data.raw["electric-pole"][config.base_name].pictures,
                straight_horizontal_single = data.raw["electric-pole"][config.base_name].pictures,
                corner_up_right = data.raw["electric-pole"][config.base_name].pictures,
                corner_up_left = data.raw["electric-pole"][config.base_name].pictures,
                corner_down_right = data.raw["electric-pole"][config.base_name].pictures,
                corner_down_left = data.raw["electric-pole"][config.base_name].pictures,
                t_up = data.raw["electric-pole"][config.base_name].pictures,
                t_down = data.raw["electric-pole"][config.base_name].pictures,
                t_left = data.raw["electric-pole"][config.base_name].pictures,
                t_right = data.raw["electric-pole"][config.base_name].pictures,
                cross = data.raw["electric-pole"][config.base_name].pictures,
                ending_up = data.raw["electric-pole"][config.base_name].pictures,
                ending_down = data.raw["electric-pole"][config.base_name].pictures,
                ending_left = data.raw["electric-pole"][config.base_name].pictures,
                ending_right = data.raw["electric-pole"][config.base_name].pictures,
                horizontal_window_background = data.raw["electric-pole"][config.base_name].pictures,
                vertical_window_background = data.raw["electric-pole"][config.base_name].pictures,
                fluid_background = data.raw["electric-pole"][config.base_name].pictures,
                low_temperature_flow = data.raw["electric-pole"][config.base_name].pictures,
                middle_temperature_flow = data.raw["electric-pole"][config.base_name].pictures,
                high_temperature_flow = data.raw["electric-pole"][config.base_name].pictures,
                gas_flow = data.raw["electric-pole"][config.base_name].pictures,
            }
        }
    }})
    data.raw["pipe"][name.."-place"].next_upgrade = nil

    -- Now create the main entity without graphics
    data:extend({util.merge{
        data.raw["pipe"][name.."-place"],
        {
            name = name,
            localised_name = {"entity-name."..config.base_name},
            localised_description={"", {"fluidic-text.pole-transmit-variant-description"}},
            minable = {result = config.base_name},  -- It will return the vanilla item
            
            -- Allows pasting of blueprints with circuits
            -- Needs to be here with the hidden entity so that
            -- blueprints still collide correctly.
            -- Note: This breaks quick-replace, since the top entity (pole)
            -- and entity-to-place (fluidic) don't have the senergy_usageame collision masks.
            -- Prefer having blueprints functioning correctly.
            collision_mask = {},
        }
    }})    
    for key, _ in pairs(data.raw["pipe"][name].pictures) do       
        data.raw["pipe"][name].pictures[key] = {
            filename = "__FluidicPower__/graphics/entities/empty.png",                
            width = 32,
            height = 32,
        }
    end
    
    -- Now update create the electric entity
    data:extend({util.merge{
        data.raw["electric-pole"][config.base_name],
        {
            name = name.."-electric",
            localised_name = {"entity-name."..config.base_name},
            localised_description={"", {"fluidic-text.pole-transmit-variant-description"}},
            minable = {result = config.base_name},
            placeable_by = {item=config.base_name,count=1}, -- This is the magic to make the pipette and blueprint work!
            supply_area_distance = 0,            
            maximum_wire_distance = config.wire_reach,
            fast_replaceable_group = "electric-pole",   -- Reinstate the fast replaceable behaviour
            draw_copper_wires = false,                  -- Don't draw copper wires!
        }
    }})
    data.raw["electric-pole"][name.."-electric"].next_upgrade = 
            config.next_upgrade_base and config.next_upgrade_base.."-electric" or nil

    -- Depending on debug option, choose which entity is exposed
    if not constants.expose_fluid_boxes then
        -- Default
        data.raw["pipe"][name].selection_box = {{0,0}, {0,0}}
        data.raw["pipe"][name].drawing_box = {{0,0}, {0,0}}
    else
        -- Debug option
        data.raw["electric-pole"][name.."-electric"].selection_box = {{0,0}, {0,0}}
        data.raw["electric-pole"][name.."-electric"].drawing_box = {{0,0}, {0,0}}
    end

    -- Add "no-no" message to now-hidden entity
    data.raw["electric-pole"][config.base_name].localised_description = {"fluidic-text.non-accessable"}
end

return Generator