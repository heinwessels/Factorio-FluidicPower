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
    horizontal_window_bounding_box = {{0,0},{0,0}},
    vertical_window_bounding_box = {{0,0},{0,0}},
    fluid_box =
    {
      base_area = 100,      
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
      }
    },
    pictures = {
        straight_vertical_single = pole.pictures.layers[1],
        straight_vertical = pole.pictures.layers[1],
        straight_vertical_window = pole.pictures.layers[1],
        straight_horizontal = pole.pictures.layers[1],
        straight_horizontal_window = pole.pictures.layers[1],        
        straight_horizontal_single = pole.pictures.layers[1],
        corner_up_right = pole.pictures.layers[1],        
        corner_up_left = pole.pictures.layers[1],        
        corner_down_right = pole.pictures.layers[1],        
        corner_down_left = pole.pictures.layers[1],        
        t_up = pole.pictures.layers[1],        
        t_down = pole.pictures.layers[1],        
        t_left = pole.pictures.layers[1],        
        t_right = pole.pictures.layers[1],        
        cross = pole.pictures.layers[1],        
        ending_up = pole.pictures.layers[1],        
        ending_down = pole.pictures.layers[1],        
        ending_left = pole.pictures.layers[1],        
        ending_right = pole.pictures.layers[1],    
        horizontal_window_background = pole.pictures.layers[1],
        vertical_window_background = pole.pictures.layers[1],
        fluid_background = pole.pictures.layers[1],
        low_temperature_flow = pole.pictures.layers[1],
        middle_temperature_flow = pole.pictures.layers[1],
        high_temperature_flow = pole.pictures.layers[1],
        gas_flow = pole.pictures.layers[1],
    }
}
for k,v in pairs(override) do
    pole[k]=v
end
data:extend({pole})
