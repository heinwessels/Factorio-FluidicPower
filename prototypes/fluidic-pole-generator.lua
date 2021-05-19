util = require("util")
constants = require("constants")
fluidic_utils = require("scripts.fluidic-utils")

local Generator = { }

------------------------------------------------------------------------------------------------------
-- IN VARIANT (SOURCE POLE)
------------------------------------------------------------------------------------------------------

function Generator.create_in_variant(config)
    -- This will create the item, recipe, and entity
    -- in the fluidic IN variant with corresponding 
    -- electrics

    -- e.g.
    --      base_name = "small-electric-pole"
    -- Will create
    --      "fluidic-small-electric-pole-in"
    --      "fluidic-small-electric-pole-in-place"

    local name = "fluidic-"..config.base_name.."-in"
    local name_place = name.."-place"
    local name_electric = name.."-electric"

    -- ITEM
    data:extend({
        util.merge{
            data.raw["item"][config.base_name],
            {
                name = name, 
                place_result = name_place,
                icon = "__FluidicPower__/graphics/icons/"..name.."-icon.png"
            }
        },
    })

    -- RECIPE
    data:extend({util.merge{
        data.raw["recipe"][config.base_name],
        {
            name = name, 
            result = name,
        }
    }})

    -- ENTITY
    local fluid_boxes
    if not config.size or config.size == nil or config.size == 1 then
        fluid_boxes = { 
            {
                production_type = "output",
                base_area = config.fluid_box_base_area or 1,
                filter = "fluidic-10-kilojoules",
                pipe_connections = {
                    { type="input-output", position = {0, 1}, max_underground_distance = config.wire_reach},
                    { type="input-output", position = {0, -1}, max_underground_distance = config.wire_reach},
                    { type="input-output", position = {1, 0}, max_underground_distance = config.wire_reach},
                    { type="input-output", position = {-1, 0}, max_underground_distance = config.wire_reach}
                },
                secondary_draw_orders = { north = -1 },
            },
        }  -- Default 1x1 sized fluidbox. Won't work for substation
    elseif config.size and config.size == 2 then
        fluid_boxes = { 
            {
                production_type = "output",        
                base_area = config.fluid_box_base_area or 1,
                filter = "fluidic-10-kilojoules",
                pipe_connections = {               
                    {type = "output", position = {-1.5, -0.5}, max_underground_distance = config.wire_reach},
                    {type = "output", position = {1.5,  -0.5}, max_underground_distance = config.wire_reach},
                    {type = "output", position = {-0.5, -1.5}, max_underground_distance = config.wire_reach},
                    {type = "output", position = { -0.5, 1.5}, max_underground_distance = config.wire_reach},
    
                    -- These connections are only for energy sensors.
                    -- Will not connect to other poles (unless placed directly adjacent)
                    -- and thus not influence fluid flow
                    {type = "output", position = {-1.5, 0.5}, max_underground_distance = 1},
                    {type = "output", position = {1.5, 0.5}, max_underground_distance = 1},
                    {type = "output", position = {0.5, -1.5,}, max_underground_distance = 1},
                    {type = "output", position = {0.5, 1.5}, max_underground_distance = 1},
                },
                secondary_draw_orders = { north = -1 },
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
            name = name_place,
            icon = "__FluidicPower__/graphics/icons/"..name.."-icon.png",
            next_upgrade = nil,             -- Upgrading done through electric item
            fast_replaceable_group = nil,
            crafting_speed = 1,
            fixed_recipe = config.fixed_recipe,
            energy_usage = config.energy_usage,
            module_specification = nil,
            allowed_effects = nil,
            module_specification = { module_slots = 0 },
            energy_source = {
                type = "electric",
                input_priority = "secondary",
                usage_priority = "secondary-input",
                drain = "0kW"  
            },            
            maximum_wire_distance = 0,
            open_sound = nil,
            close_sound = nil,            
            crafting_categories = {"fluidic-generate"},
            fluid_boxes = fluid_boxes,            
            animation = data.raw["electric-pole"][config.base_name].pictures,
        }
    }})
    table.insert(data.raw["assembling-machine"][name_place].flags, "not-rotatable")
    table.insert(data.raw["assembling-machine"][name_place].flags, "hide-alt-info")
    data.raw["assembling-machine"][name_place].animation.layers[1].filename = 
            "__FluidicPower__/graphics/entities/electric-poles/"..config.base_name..".png"
    data.raw["assembling-machine"][name_place].animation.layers[1].hr_version.filename = 
            "__FluidicPower__/graphics/entities/electric-poles/hr-"..config.base_name..".png"
    data.raw["assembling-machine"][name_place].minable.result = nil

    -- Now create the main entity without graphics
    data:extend({util.merge{
        data.raw["assembling-machine"][name_place],
        {
            name = name,
        }
    }})    
    data.raw["assembling-machine"][name].next_upgrade = config.next_upgrade or nil
    data.raw["assembling-machine"][name].animation = {
        filename = "__FluidicPower__/graphics/entities/empty.png",                
        width = 32,
        height = 32,
    }

    -- Now update create the electric entity
    data:extend({util.merge{
        data.raw["electric-pole"][config.base_name],
        {
            name = name_electric,
            icon = "__FluidicPower__/graphics/icons/"..name.."-icon.png",
            minable = {result = name},            
            placeable_by = {item=name,count=1}, -- This is the magic to make the pipette and blueprint work!
            maximum_wire_distance = config.wire_reach + (config.size or 0),  -- Make sure we can reach the extended length
            fast_replaceable_group = nil,
        }
    }})
    table.insert(data.raw["electric-pole"][name_electric].flags, "not-upgradable")
    data.raw["electric-pole"][name_electric].pictures.layers[1].filename = 
            "__FluidicPower__/graphics/entities/electric-poles/"..config.base_name..".png"
    data.raw["electric-pole"][name_electric].pictures.layers[1].hr_version.filename = 
            "__FluidicPower__/graphics/entities/electric-poles/hr-"..config.base_name..".png"

    -- Depending on debug option, choose which entity is exposed (electric[default] or fluid)
    if not constants.expose_fluid_boxes then
        -- Default fluid is not exposed
        data.raw["assembling-machine"][name].selection_box = {{0,0}, {0,0}}
        data.raw["assembling-machine"][name].drawing_box = {{0,0}, {0,0}}
    else
        -- Debug option
        data.raw["electric-pole"][name_electric].selection_box = {{0,0}, {0,0}}
        data.raw["electric-pole"][name_electric].drawing_box = {{0,0}, {0,0}}
    end
end

------------------------------------------------------------------------------------------------------
-- OUT VARIANT (NORMAL ONE)
------------------------------------------------------------------------------------------------------

function Generator.create_out_variant(config)
    -- This will create the item, recipe, and entity
    -- in the fluidic OUT variant with corresponding 
    -- electrics

    -- e.g.
    --      base_name = "small-electric-pole"
    -- Will create
    --      "fluidic-small-electric-pole-out"
    --      "fluidic-small-electric-pole-in-place"

    local name = "fluidic-"..config.base_name.."-out"
    local name_place = name.."-place"
    local name_electric = name.."-electric"

    -- ITEM
    data:extend({
        util.merge{
            data.raw["item"][config.base_name],
            {
                name = name, 
                place_result = name_place,
            }
        },
    })

    -- RECIPE
    data:extend({util.merge{
        data.raw["recipe"][config.base_name],
        {
            name = name, 
            result = name,
        }
    }})

    -- ENTITY
    -- First create the entity that will be placed
    local fluid_boxes
    if not config.size or config.size == nil or config.size == 1 then
        fluid_boxes = {
            base_area = config.fluid_box_base_area or 1,
            pipe_connections =
            {
                {type = "input-output", position = {-1, 0}, max_underground_distance =config.wire_reach},
                {type = "input-output", position = {1, 0}, max_underground_distance = config.wire_reach},
                {type = "input-output", position = {0, -1}, max_underground_distance = config.wire_reach},
                {type = "input-output", position = {0, 1}, max_underground_distance = config.wire_reach},
            },
            production_type = "input-output",
            minimum_temperature = 10,
            filter = "fluidic-10-kilojoules"
        }
    elseif config.size and config.size == 2 then
        fluid_boxes = {
            base_area = 1,
            pipe_connections =
            {
                {type = "input-output", position = {-1.5, -0.5}, max_underground_distance = config.wire_reach},
                {type = "input-output", position = {1.5,  -0.5}, max_underground_distance = config.wire_reach},
                {type = "input-output", position = {-0.5, -1.5}, max_underground_distance = config.wire_reach},
                {type = "input-output", position = { -0.5, 1.5}, max_underground_distance = config.wire_reach},
    
                -- These connections are only for energy sensors.
                -- Will not connect to other poles (unless placed directly adjacent)
                -- and thus not influence fluid flow
                {type = "input-output", position = {-1.5, 0.5}, max_underground_distance = 1},
                {type = "input-output", position = {1.5, 0.5}, max_underground_distance = 1},
                {type = "input-output", position = {0.5, -1.5,}, max_underground_distance = 1},
                {type = "input-output", position = {0.5, 1.5}, max_underground_distance = 1},
            },
            production_type = "input-output",        
            minimum_temperature = 10,
            filter = "fluidic-10-kilojoules"
        }
    else
        error("Invalid pole size specified: "..config.size)
    end

    data:extend({util.merge{
        data.raw["electric-pole"][config.base_name],
        {
            type = "generator",
            name = name_place,
            next_upgrade = nil,             -- Upgrading done through electric item            
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
    table.insert(data.raw["generator"][name_place].flags, "not-rotatable")
    table.insert(data.raw["generator"][name_place].flags, "hide-alt-info")
    data.raw["generator"][name_place].minable.result = nil

    -- Now create the main entity without graphics
    data:extend({util.merge{
        data.raw["generator"][name_place],
        {
            name = name,
        }
    }})
    data.raw["generator"][name].vertical_animation = {
        filename = "__FluidicPower__/graphics/entities/empty.png",                
        width = 32,
        height = 32,
    }
    data.raw["generator"][name].horizontal_animation = {
        filename = "__FluidicPower__/graphics/entities/empty.png",                
        width = 32,
        height = 32,
    }

    -- Now update create the electric entity
    data:extend({util.merge{
        data.raw["electric-pole"][config.base_name],
        {
            name = name_electric,
            minable = {result = name},
            placeable_by = {item=name,count=1}, -- This is the magic to make the pipette and blueprint work!
            maximum_wire_distance = config.wire_reach + (config.size or 0),  -- Make sure we can reach the extended length            
        }
    }})
    table.insert(data.raw["electric-pole"][name_electric].flags, "not-upgradable")

    -- Depending on debug option, choose which entity is exposed
    if not constants.expose_fluid_boxes then
        -- Default
        data.raw["generator"][name].selection_box = {{0,0}, {0,0}}
    else
        -- Debug option
        data.raw["electric-pole"][name_electric].selection_box = {{0,0}, {0,0}}
    end
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
    local name_place = name.."-place"
    local name_electric = name.."-electric"

    -- ITEM
    data:extend({
        util.merge{
            data.raw["item"][config.base_name],
            {
                name = name, 
                place_result = name_place,
            }
        },
    })

    -- RECIPE
    data:extend({util.merge{
        data.raw["recipe"][config.base_name],
        {
            name = name, 
            result = name,
        }
    }})

    -- ENTITY
    -- First create the entity that will be used while placing
    data:extend({util.merge{
        data.raw["electric-pole"][config.base_name],
        {
            type = "pipe",
            name = name_place,
            minable = {result = name},
            horizontal_window_bounding_box = {{0,0},{0,0}},
            vertical_window_bounding_box = {{0,0},{0,0}},            
            fluid_box =
            {
                base_area = 1,               
                pipe_connections =
                {
                    {type = "input-output", position = {-1.5, -0.5}, max_underground_distance = config.wire_reach},
                    {type = "input-output", position = {1.5, -0.5}, max_underground_distance = config.wire_reach},
                    {type = "input-output", position = { -0.5, -1.5,}, max_underground_distance = config.wire_reach},
                    {type = "input-output", position = { -0.5, 1.5}, max_underground_distance = config.wire_reach},


                    -- These connections are only for energy sensors.
                    -- Will not connect to other poles (unless placed directly adjacent)
                    -- and thus not influence fluid flow
                    {type = "input-output", position = {-1.5, 0.5}, max_underground_distance = 1},
                    {type = "input-output", position = {1.5, 0.5}, max_underground_distance = 1},
                    {type = "input-output", position = {0.5, -1.5,}, max_underground_distance = 1},
                    {type = "input-output", position = {0.5, 1.5}, max_underground_distance = 1},
                },
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
    table.insert(data.raw["pipe"][name_place].flags, "not-rotatable")

    -- Now create the main entity without graphics
    data:extend({util.merge{
        data.raw["pipe"][name_place],
        {
            name = name,
            minable = {result = name},  -- It will return the normal item            
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
            name = name_electric,
            minable = {result = name},
            placeable_by = {item=name,count=1}, -- This is the magic to make the pipette and blueprint work!
            supply_area_distance = 0,
            next_upgrade = nil,                  -- Upgrade should be done through base entity

            -- Because the wires come from the middle of the entity, and the 
            -- pipes from the side, the max_wire_dist needs to be slightly longer
            -- If it's a 2x2 entity
            maximum_wire_distance = config.wire_reach + (config.size or 0)
        }
    }})    

    -- Depending on debug option, choose which entity is exposed
    if not constants.expose_fluid_boxes then
        -- Default
        data.raw["pipe"][name].selection_box = {{0,0}, {0,0}}
        data.raw["pipe"][name].drawing_box = {{0,0}, {0,0}}
    else
        -- Debug option
        data.raw["electric-pole"][name_electric].selection_box = {{0,0}, {0,0}}
        data.raw["electric-pole"][name_electric].drawing_box = {{0,0}, {0,0}}
    end
end

return Generator