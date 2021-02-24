data:extend
({   
    {
        type = "item",
        name = "fluidic-big-pole",
		icon_size = 64,
	    place_result = "fluidic-big-pole",
        icon = "__base__/graphics/icons/big-electric-pole.png",
		subgroup = "energy-pipe-distribution",
        order = "a[energy]-a[big-electric-pole]",
        stack_size = 50
    }
})

local pole = table.deepcopy(data.raw["electric-pole"]["big-electric-pole"])
override = {
    type = "pipe",
    name = "fluidic-big-pole",
    minable = {mining_time = 0.5, result = "fluidic-big-pole"},
    horizontal_window_bounding_box = {{0,0},{0,0}},
    vertical_window_bounding_box = {{0,0},{0,0}},
    fluid_box =
    {     
        height = 2,
        pipe_connections =
        {
            {type = "input-output", position = {-1.5, 0.5}, max_underground_distance = 30},        
            {type = "input-output", position = {-1.5, -0.5}, max_underground_distance = 30},
            {type = "input-output", position = {1.5, 0.5}, max_underground_distance = 30},
            {type = "input-output", position = {1.5, -0.5}, max_underground_distance = 30},

            {type = "input-output", position = { 0.5, -1.5,}, max_underground_distance = 30},        
            {type = "input-output", position = {-0.5, -1.5}, max_underground_distance = 30},
            {type = "input-output", position = { 0.5, 1.5}, max_underground_distance = 30},
            {type = "input-output", position = {-0.5, 1.5}, max_underground_distance = 30},
        },
    },
    pictures = {
        straight_vertical_single = pole.pictures,
        straight_vertical = pole.pictures,
        straight_vertical_window = pole.pictures,
        straight_horizontal = pole.pictures,
        straight_horizontal_window = pole.pictures,
        straight_horizontal_single = pole.pictures,
        corner_up_right = pole.pictures,
        corner_up_left = pole.pictures,
        corner_down_right = pole.pictures,
        corner_down_left = pole.pictures,
        t_up = pole.pictures,
        t_down = pole.pictures,
        t_left = pole.pictures,
        t_right = pole.pictures,
        cross = pole.pictures,
        ending_up = pole.pictures,
        ending_down = pole.pictures,
        ending_left = pole.pictures,
        ending_right = pole.pictures,
        horizontal_window_background = pole.pictures,
        vertical_window_background = pole.pictures,
        fluid_background = pole.pictures,
        low_temperature_flow = pole.pictures,
        middle_temperature_flow = pole.pictures,
        high_temperature_flow = pole.pictures,
        gas_flow = pole.pictures,
    }
}
for k,v in pairs(override) do
    pole[k]=v
end
data:extend({pole})
