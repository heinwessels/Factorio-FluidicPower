util = require("util")
constants = require("constants")
fluidic_utils = require("scripts.fluidic-utils")

local Generator = { }

local empty_animation = {
    filename = "__FluidicPower__/graphics/entities/empty.png",                
    width = 32,
    height = 32,
}

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
            place_result =  name.."-in-place",
            stack_size = item_out.stack_size,
            subgroup = item_out.subgroup,
            order = item_out.order,
            icons = {
                {
                    icon = item_out.icon,
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
            ingredients = {{config.base_name, 1}},
            results = {{type = "item", name = name.."-in", amount = 1}},
            energy_required = 0.2,
            enabled = false, -- By default
        }
    })

    -- Power fluid generation recipe
    data:extend({
        util.merge{
            {
                type = "recipe",
                name = "fluidic-generate-"..config.base_name,
                icon_size = 64,
                icon = "__FluidicPower__/graphics/icons/energy-fluid-base.png",
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
    local base_pole = data.raw["electric-pole"][config.base_name]
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

        -- First create PLACE entity. This entity is the same as the
        -- hidden fluidic entity, which for the source pole is an assembler
        -- This assembler turns electricity into a power fluid
        local pole_in_place = {
            type = "assembling-machine",
            name = name.."-in-place",
            localised_name = {"", {"fluidic-text.pole-in-variant", {"entity-name."..config.base_name}}},
            localised_description={"", 
                {"fluidic-text.pole-in-variant-description"},
                "\n",
                {"fluidic-text.pole-wire-description", config.wire_reach, base_pole.supply_area_distance*2},
            },
            
            icon_size = base_pole.icon_size, 
            icon_mipmaps = base_pole.icon_mipmaps,
            icons = {
                {
                    icon = base_pole.icon,
                    tint = tint_in
                }                    
            },

            minable = {result = name.."-in", mining_time=base_pole.minable.mining_time},
            resistances = base_pole.resistances,
            max_health = base_pole.max_health,
            flags = {
                "not-rotatable", 
                "hide-alt-info", 
                "placeable-neutral", 
                "fast-replaceable-no-build-while-moving", 
                "not-flammable",
                "player-creation",  -- Allows to place ghosts with shift-click
                "not-upgradable",   -- Upgrades are done through electric entity
            },
            
            collision_box = base_pole.collision_box,
            selection_box = base_pole.selection_box,
            
            crafting_speed = 1,
            fixed_recipe = "fluidic-generate-"..config.base_name,
            energy_usage = config.energy_usage,
            module_specification = { module_slots = 0 },
            energy_source = {
                type = "electric",
                usage_priority = "secondary-input",
                drain = "0kW",
                render_no_network_icon = false,
                render_no_power_icon = false,
            },
            open_sound = nil,
            close_sound = nil,            
            crafting_categories = {"fluidic-generate"},
            fluid_boxes = fluid_boxes,            
            animation = util.table.deepcopy(base_pole.pictures),
        }
        pole_in_place.animation.layers[1].tint = tint_in
        pole_in_place.animation.layers[1].hr_version.tint = tint_in
        if mods["BottleneckLite"] then
            pole_in_place.bottleneck_ignore = true   -- For BottleNeck Lite
        end

        -- Now create the main entity without graphics
        local pole_in = util.merge{
            pole_in_place,
            {
                name = name.."-in",

                -- Allows pasting of blueprints with circuits
                -- Needs to be here with the hidden entity so that
                -- blueprints still collide correctly.
                -- Note: This breaks quick-replace, since the top entity (pole)
                -- and entity-to-place (fluidic) don't have the same collision masks.
                -- Prefer having blueprints functioning correctly.
                collision_mask = {},
            }
        }
        pole_in.animation = empty_animation

        -- Now update create the electric entity
        local pole_in_electric = util.merge{
            base_pole,
            {
                name = name.."-in-electric",
                localised_name = {"", {"fluidic-text.pole-in-variant", {"entity-name."..config.base_name}}},
                localised_description={"", 
                    {"fluidic-text.pole-in-variant-description"},
                    "\n",
                    {"fluidic-text.power-rating", config.energy_usage}
                },
                icons = pole_in.icons,
                minable = {result = name.."-in"},
                placeable_by = {item=name.."-in",count=1}, -- This is the magic to make the pipette and blueprint work!
                maximum_wire_distance = config.wire_reach,  -- Make sure we can reach the extended length
                fast_replaceable_group = "electric-pole",   -- Reinstate the fast replaceable behaviour
                draw_copper_wires = false,                  -- Don't draw copper wires!
            }
        }
        pole_in_electric.icon = nil
        pole_in_electric.next_upgrade = config.next_upgrade_base and config.next_upgrade_base.."-in-electric" or nil
        pole_in_electric.pictures.layers[1].tint = tint_in
        pole_in_electric.pictures.layers[1].hr_version.tint = tint_in

        -- Depending on debug option, choose which entity is exposed (electric[default] or fluid)
        if not constants.expose_fluid_boxes then
            -- Default fluid is not exposed
            pole_in.selection_box = {{0,0}, {0,0}}
            pole_in.drawing_box = {{0,0}, {0,0}}
        else
            -- Debug option
            pole_in_electric.selection_box = {{0,0}, {0,0}}
            pole_in_electric.drawing_box = {{0,0}, {0,0}}
        end

        data:extend{pole_in_place, pole_in, pole_in_electric}
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

        local pole_out_place = {
            type = "generator",
            name = name.."-out-place",
            localised_name = {"", {"fluidic-text.pole-out-variant", {"entity-name."..config.base_name}}},
            localised_description={"", 
                {"fluidic-text.pole-out-variant-description"},
                "\n",
                {"fluidic-text.pole-wire-description", config.wire_reach, base_pole.supply_area_distance*2},
            },

            icon = base_pole.icon,
            icons = base_pole.icons,
            icon_size = base_pole.icon_size, 
            icon_mipmaps = base_pole.icon_mipmaps,
            
            -- This is required for when the item may not be placed due to fluids-mixing
            minable = {result = config.base_name, mining_time=base_pole.minable.mining_time},
            resistances = base_pole.resistances,
            max_health = base_pole.max_health,
            flags = {
                "not-rotatable", 
                "hide-alt-info", 
                "placeable-neutral", 
                "fast-replaceable-no-build-while-moving", 
                "not-flammable",
                "player-creation",  -- Allows to place ghosts with shift-click
                "not-upgradable",   -- Upgrades are done through electric entity
            },

            collision_box = base_pole.collision_box,
            selection_box = base_pole.selection_box,

            effectivity = 1,
            maximum_temperature = 15,
            fluid_usage_per_tick = config.fluid_usage_per_tick,  -- Default energy output. value = P / 60
            burns_fluid = true,
            fluid_box = fluid_boxes,
            energy_source =
            {
                type = "electric",
                
                -- This is secondary to work with the Electric Energy Interface (?)
                -- but it creates a feedback loop when placed right next to a source
                -- pole. This will force user to not overlap two poles at power generation.
                usage_priority = "secondary-output" 
            },
            vertical_animation = util.table.deepcopy(base_pole.pictures),
            horizontal_animation = util.table.deepcopy(base_pole.pictures),
        }
        if mods["BottleneckLite"] then
            pole_out_place.bottleneck_ignore = true   -- For BottleNeck Lite
        end

        -- Now create the main entity without graphics        
        local pole_out = util.merge{
            pole_out_place,
            {
                name = name.."-out",
                next_upgrade = nil,
                
                -- Allows pasting of blueprints with circuits
                -- Needs to be here with the hidden entity so that
                -- blueprints still collide correctly.
                -- Note: This breaks quick-replace, since the top entity (pole)
                -- and entity-to-place (fluidic) don't have the same collision masks.
                -- Prefer having blueprints functioning correctly.
                collision_mask = {},
            }
        }
        pole_out.vertical_animation = empty_animation
        pole_out.horizontal_animation = empty_animation

        -- Now update create the electric entity
        local pole_out_electric = util.merge{
            base_pole,
            {
                name = name.."-out-electric",
                localised_name = {"", {"fluidic-text.pole-out-variant", {"entity-name."..config.base_name}}},
                localised_description={"", 
                    {"fluidic-text.pole-out-variant-description"},
                    "\n",
                    {"fluidic-text.power-rating", config.energy_usage}
                },
                minable = {result = config.base_name},
                placeable_by = {item=config.base_name,count=1}, -- This is the magic to make the pipette and blueprint work!
                maximum_wire_distance = config.wire_reach,  -- Make sure we can reach the extended length
                fast_replaceable_group = "electric-pole",   -- Reinstate the fast replaceable behaviour
                draw_copper_wires = false,                  -- Don't draw copper wires!
            }
        }
        pole_out_electric.next_upgrade = config.next_upgrade_base and config.next_upgrade_base.."-out-electric" or nil

        -- Depending on debug option, choose which entity is exposed
        if not constants.expose_fluid_boxes then
            -- Default
            pole_out.selection_box = {{0,0}, {0,0}}        
        else
            -- Debug option
            pole_out_electric.selection_box = {{0,0}, {0,0}}
        end
        
        data:extend{pole_out_place, pole_out, pole_out_electric}
    end

    -- Add "no-no" message to now-hidden entity
    base_pole.localised_description = {"fluidic-text.non-accessable"}

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

    -- ENTITIES    
    local base_pole = data.raw["electric-pole"][config.base_name]
    
    -- First create the entity that will be used while placing    
    local pipe_offset = -math.floor(config.size / 2)
    local pole_fluidic_place = {
        type = "pipe",
        name = name.."-place",
        localised_name = {"entity-name."..config.base_name},
        localised_description={"", {"fluidic-text.pole-transmit-variant-description"}},
        minable = {result = config.base_name, mining_time=base_pole.minable.mining_time},
        resistances = base_pole.resistances,
        horizontal_window_bounding_box = {{0,0},{0,0}},
        vertical_window_bounding_box = {{0,0},{0,0}},
        
        icon = base_pole.icon,
        icons = base_pole.icons,
        icon_size = base_pole.icon_size, 
        icon_mipmaps = base_pole.icon_mipmaps,

        collision_box = base_pole.collision_box,
        selection_box = base_pole.selection_box,
        max_health = base_pole.max_health,

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
            straight_vertical_single = util.table.deepcopy(base_pole.pictures),
            straight_vertical = util.table.deepcopy(base_pole.pictures),
            straight_vertical_window = util.table.deepcopy(base_pole.pictures),
            straight_horizontal = util.table.deepcopy(base_pole.pictures),
            straight_horizontal_window = util.table.deepcopy(base_pole.pictures),
            corner_up_right = util.table.deepcopy(base_pole.pictures),
            corner_up_left = util.table.deepcopy(base_pole.pictures),
            corner_down_right = util.table.deepcopy(base_pole.pictures),
            corner_down_left = util.table.deepcopy(base_pole.pictures),
            t_up = util.table.deepcopy(base_pole.pictures),
            t_down = util.table.deepcopy(base_pole.pictures),
            t_left = util.table.deepcopy(base_pole.pictures),
            t_right = util.table.deepcopy(base_pole.pictures),
            cross = util.table.deepcopy(base_pole.pictures),
            ending_up = util.table.deepcopy(base_pole.pictures),
            ending_down = util.table.deepcopy(base_pole.pictures),
            ending_left = util.table.deepcopy(base_pole.pictures),
            ending_right = util.table.deepcopy(base_pole.pictures),
            horizontal_window_background = util.table.deepcopy(base_pole.pictures),
            vertical_window_background = util.table.deepcopy(base_pole.pictures),
            fluid_background = util.table.deepcopy(base_pole.pictures),
            low_temperature_flow = util.table.deepcopy(base_pole.pictures),
            middle_temperature_flow = util.table.deepcopy(base_pole.pictures),
            high_temperature_flow = util.table.deepcopy(base_pole.pictures),
            gas_flow = util.table.deepcopy(base_pole.pictures),
        }
    }
    if mods["BottleneckLite"] then
        pole_fluidic_place.bottleneck_ignore = true   -- For BottleNeck Lite
    end

    -- Now create the main entity without graphics
    local pole_fluidic = util.merge{
        pole_fluidic_place,
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
    }
    for key, _ in pairs(pole_fluidic.pictures) do       
        pole_fluidic.pictures[key] = empty_animation
    end
    
    -- Now update create the electric entity
    local pole_electric = util.merge{
        base_pole,
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
    }
    pole_electric.next_upgrade = config.next_upgrade_base and config.next_upgrade_base.."-electric" or nil

    -- Depending on debug option, choose which entity is exposed
    if not constants.expose_fluid_boxes then
        -- Default
        pole_fluidic.selection_box = {{0,0}, {0,0}}
        pole_fluidic.drawing_box = {{0,0}, {0,0}}
    else
        -- Debug option
        pole_electric.selection_box = {{0,0}, {0,0}}
        pole_electric.drawing_box = {{0,0}, {0,0}}
    end

    -- Add "no-no" message to now-hidden entity
    data.raw["electric-pole"][config.base_name].localised_description = {"fluidic-text.non-accessable"}

    data:extend{pole_fluidic_place, pole_fluidic, pole_electric}
end

return Generator