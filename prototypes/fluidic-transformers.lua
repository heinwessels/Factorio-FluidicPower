local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local util = require("util")

local function create_icon(from, to, direction)
    local from_icons = data.raw.fluid[from].icons
    local to_icons = data.raw.fluid[to].icons
    local icons = {{
        icon = "__FluidicPower__/graphics/icons/"..direction..".png",
        icon_size = 35, icon_mipmaps = 1,
    }}

    local scale = 0.65
    local shift = {10, 8}
    if direction == "up" then shift[2] = -shift[2] end
    return util.combine_icons(
        util.combine_icons(icons, from_icons, 
            {scale=scale, shift={-shift[1], -shift[2]}}),
            to_icons, {scale=scale, shift=shift})
end

-- Create some recipes
data:extend
({ 
    ------------------------
    -- Item
    ------------------------
    {
        type = "item",
        name = "fluidic-transformer",
        place_result = "fluidic-transformer",
        icon = "__FluidicPower__/graphics/icons/transformer-icon.png",
        icon_size = 32, icon_mipmaps = 1,
        subgroup = "energy-pipe-distribution",
        order = "a[energy]-z[transformer]",
        stack_size = 20
    },
    
    ------------------------
    -- Recipe
    ------------------------
    {
        type = "recipe",
        name = "fluidic-transformer",
        enabled = false,
        ingredients =
        {
            {"steel-plate", 20},
            {"advanced-circuit", 20},
            {"copper-cable", 30}
        },
        energy_required = 3,
        result = "fluidic-transformer"
    },

    ------------------------
    -- TRANSFORMER RECIPES
    ------------------------
    -- POWER rating forumla
    -- P = o * u / t
    --      where:
    --          o : number of output units
    --          u : unit of output units
    --          t : time per craft (energy required)
    {
        type = "recipe-category",
        name = "fluidic-transformers"
    },
    {
        type = "item-subgroup",
        name = "fluidic-transformer-up",
        group = "fluids",
        order = "a"
    },
    {
        type = "item-subgroup",
        name = "fluidic-transformer-down",
        group = "fluids",
        order = "b"
    },
    {
        type = "recipe",
        name = "fluidic-10-kilo-to-megajoules",
        icons = create_icon("fluidic-10-kilojoules", "fluidic-megajoules", "up"),
        category = "fluidic-transformers",
        order = "a[a]-a[a]",
        subgroup = "fluidic-transformer-up",
        hide_from_stats = true, -- Hide stats to not influence production/consumption stats
        hide_from_player_crafting = true,

        -- Currently 50MW
        ingredients ={{type="fluid", name="fluidic-10-kilojoules", amount=1000}},
        results={{type="fluid", name="fluidic-megajoules", amount=10}},
        energy_required = 0.2,
    },
    {
        type = "recipe",
        name = "fluidic-mega-to-100-megajoules",
        icons = create_icon("fluidic-megajoules", "fluidic-100-megajoules", "up"),
        order = "a[c]-a[100-megajoules]",
        category = "fluidic-transformers",
        subgroup = "fluidic-transformer-up",
        hide_from_stats = true, -- Hide stats to not influence production/consumption stats
        hide_from_player_crafting = true,
        
        -- Currently 500MW
        ingredients ={{type="fluid", name="fluidic-megajoules", amount=100}},
        results={{type="fluid", name="fluidic-100-megajoules", amount=1}},
        energy_required = 0.2,
    },    
    {
        type = "recipe",
        name = "fluidic-mega-to-10-kilojoules",
        icons = create_icon("fluidic-megajoules", "fluidic-10-kilojoules", "down"),
        order = "a[b]-a[b]",
        category = "fluidic-transformers",
        subgroup = "fluidic-transformer-down",
        hide_from_stats = true, -- Hide stats to not influence production/consumption 
        hide_from_player_crafting = true,
        
        -- Currently 50MW
        ingredients ={{type="fluid", name="fluidic-megajoules", amount=10}},
        results={{type="fluid", name="fluidic-10-kilojoules", amount=1000}},
        energy_required = 0.2,
    },
    {
        type = "recipe",
        name = "fluidic-100-mega-to-megajoule",
        icons = create_icon("fluidic-100-megajoules", "fluidic-megajoules", "down"),
        category = "fluidic-transformers",
        subgroup = "fluidic-transformer-down",
        order = "a[d]-a[megajoules]",
        hide_from_stats = true, -- Hide stats to not influence production/consumption stats
        hide_from_player_crafting = true,
        
        -- Currently 500MW
        ingredients ={{type="fluid", name="fluidic-100-megajoules", amount=1}},
        results={{type="fluid", name="fluidic-megajoules", amount=100}},
        energy_required = 0.2,  -- This limits power throughput
    }
})

-- Create the entities
data:extend({
    {
        type = "assembling-machine",
        name = "fluidic-transformer",
        localised_description = {"fluidic-text.transformer"},
        icon = "__FluidicPower__/graphics/icons/transformer-icon.png",
        icon_size = 32,
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.2, result = "fluidic-transformer"},
        max_health = 400,
        corpse = "assembling-machine-1-remnants",
        dying_explosion = "assembling-machine-1-explosion",
        crafting_categories = {"fluidic-transformers"},
        allowed_effects = {},
        module_specification = {module_slots=0},
        crafting_speed = 1,
        resistances =
        {
            {
                type = "fire",
                percent = 70
            }
        },
        collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
        selection_box = {{-1, -1}, {1, 1}},
        damaged_trigger_effect = hit_effects.entity(),
        energy_usage = "1W",    -- Not used
        energy_source = { type = "void" },
        fluid_boxes =
        {
            -- Would like to have less fluid connections here, 
            -- similar to big poles, substations and accumulators
            -- But, needs to be rotatable without issues.
            {
                production_type = "input",        
                base_area = 1,
                base_level = -1,
                height = 1,
                pipe_connections = {
                    {type = "input", position = {-1.5, 0.5}, max_underground_distance = 4},
                    {type = "input", position = {-1.5, -0.5}, max_underground_distance = 4},
                },        
            },
            {

                production_type = "output",        
                base_area = 1,
                base_level = 1,
                -- Source box higher to aid pushing the fluid out just like pumps
                -- Also, subsequent poles only fill up to about 60% if we don't increase this
                height = 2,
                pipe_connections = {
                    {type = "output", position = {1.5, 0.5}, max_underground_distance = 4},        
                    {type = "output", position = {1.5, -0.5}, max_underground_distance = 4},
                },        
            },
        }, 
        animation =
        {
            layers =
            {
                {
                    filename = "__FluidicPower__/graphics/entities/transformers/transformer-antenna-shadow.png",
                    width = 63,
                    height = 49,
                    line_length = 8,
                    frame_count = 32,
                    shift = { 2.015, 0.34},
                    animation_speed = 2,
                    scale = 0.6
                },
                {
                    filename = "__FluidicPower__/graphics/entities/transformers/transformer-base-sheet.png",
                    width = 116,
                    height = 93,
                    frame_count = 32,
                    line_length = 8,
                    frame_count = 32,
                    shift = { 0.23, 0.046875},
                    scale = 0.66
                },                
                {
                    filename = "__FluidicPower__/graphics/entities/transformers/transformer-antenna.png",
                    width = 54,
                    height = 50,
                    line_length = 8,
                    frame_count = 32,
                    shift = { 0, -1.2},
                    animation_speed = 2,
                    scale = 0.8
                },                
            },
        },   
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        vehicle_impact_sound = sounds.generic_impact,
        working_sound =
        {
            sound =
            {
              filename = "__base__/sound/accumulator-working.ogg",
              volume = 0.5
            },
            idle_sound =
            {
              filename = "__base__/sound/accumulator-idle.ogg",
              volume = 0.35
            },
            max_sounds_per_type = 3,
            audible_distance_modifier = 0.6,
            fade_in_ticks = 2,
            fade_out_ticks = 20
        },
    },
})