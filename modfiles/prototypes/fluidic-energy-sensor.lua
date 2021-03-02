data:extend({
    {
        type = "item",
        name = "fluidic-energy-sensor",
        place_result = "fluidic-energy-sensor",
        icon = "__FluidicPower__/graphics/icons/energy-sensor-icon.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "circuit-network",
        order = "d[other]-a[energy-sensor]",
        stack_size = 50
    },
    {
        type = "recipe",
        name = "fluidic-energy-sensor",
        enabled = false,
        energy_required = 2,
        ingredients =
        {
            -- Similar to power switch
            {"steel-plate", 2},
            {"copper-cable", 5},
            {"electronic-circuit", 2}
        },
        result = "fluidic-energy-sensor"
    },
    {
        type = "storage-tank",
        name = "fluidic-energy-sensor",
        icon = "__FluidicPower__/graphics/icons/energy-sensor-icon.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"placeable-player", "player-creation"},
        minable = {mining_time = 0.2, result = "fluidic-energy-sensor"},
        max_health = 100,
        corpse = "iron-chest-remnants",
        dying_explosion = "iron-chest-explosion",
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        flow_length_in_ticks = 360,
        two_direction_only = true,  -- TODO What does this even do?
        window_bounding_box = {{-0.3, -0.45}, {0.1, -0.1}},
        fluid_box =
        {
            base_area = 1,
            pipe_connections =
            {
                { type="input-output", position = {0, 1}, max_underground_distance = 1},
                { type="input-output", position = {0, -1}, max_underground_distance = 1},
                { type="input-output", position = {1, 0}, max_underground_distance = 1},
                { type="input-output", position = {-1, 0}, max_underground_distance = 1},
            }
        },        
        pictures = {
            picture =
            {
                layers =
                {
                    {
                        filename = "__FluidicPower__/graphics/entities/energy-sensor/energy-sensor.png",
                        priority = "extra-high",
                        width = 34,
                        height = 38,
                        shift = util.by_pixel(0, -0.5),
                        hr_version =
                        {
                            filename = "__FluidicPower__/graphics/entities/energy-sensor/hr-energy-sensor.png",
                            priority = "extra-high",
                            width = 66,
                            height = 76,
                            shift = util.by_pixel(-0.5, -0.5),
                            scale = 0.5
                        }
                    },
                    table.deepcopy(data.raw["container"]["iron-chest"].picture.layers[2])                    
                }
            },
            fluid_background = table.deepcopy(data.raw["storage-tank"]["storage-tank"].pictures.fluid_background),
            window_background = table.deepcopy(data.raw["storage-tank"]["storage-tank"].pictures.window_background),
            flow_sprite = table.deepcopy(data.raw["storage-tank"]["storage-tank"].pictures.flow_sprite),
            gas_flow = table.deepcopy(data.raw["storage-tank"]["storage-tank"].pictures.gas_flow),
        },
        working_sound =
        {
          sound =
          {
              filename = "__base__/sound/storage-tank.ogg",
              volume = 0.6
          },
          match_volume_to_activity = true,
          audible_distance_modifier = 0.5,
          max_sounds_per_type = 3
        },
        -- TODO Fix stupid circuit wires
        circuit_wire_connection_points = {
            circuit_connector_definitions["chest"].points,
            circuit_connector_definitions["chest"].points,
        },
        circuit_wire_connection_points = circuit_connector_definitions["offshore-pump"].points,
        circuit_connector_sprites = circuit_connector_definitions["offshore-pump"].sprites,
        circuit_wire_max_distance = default_circuit_wire_max_distance
    }
})
data.raw["storage-tank"]["fluidic-energy-sensor"].pictures.fluid_background.width = 14
data.raw["storage-tank"]["fluidic-energy-sensor"].pictures.window_background.scale = 0.75
data.raw["storage-tank"]["fluidic-energy-sensor"].pictures.window_background.hr_version.width = 20  -- Hacking to not overlap
data.raw["storage-tank"]["fluidic-energy-sensor"].pictures.window_background.hr_version.height = 20  -- Hacking to not overlap
data.raw["storage-tank"]["fluidic-energy-sensor"].pictures.window_background.hr_version.scale = 0.75