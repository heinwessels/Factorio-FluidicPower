local styles = data.raw["gui-style"].default

styles["fluidic-content-frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    vertically_stretchable = "on"
}

styles["fluidic-consumption-bar"] = {
    type = "progressbar_style",
    font_color={r=230/255, g=227/255, b=230/255},
    filled_font_color={r=0/255, g=0/255, b=0/255},
    bar_width = 28,
    embed_text_in_bar=true,
    font="default-bold",
    vertical_align="center",
    horizontal_align = "right",
    horizontally_stretchable = "stretch_and_expand",
    bar_background=table.deepcopy(styles["progressbar"].bar_background),
    color = {43, 227, 39},
}

styles["fluidic-production-bar"] = {
    type = "progressbar_style",
    parent = "fluidic-consumption-bar",
    other_colors =
    {
      {less_than = 0.5, color = {218, 69, 53}},
      {less_than = 0.8, color = {219, 176, 22}}
    }
}