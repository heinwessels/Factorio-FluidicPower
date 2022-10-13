local styles = data.raw["gui-style"].default

styles["fluidic-main-frame"] = {
    type = "frame_style",
    vertically_stretchable = "off"
}

styles["fluidic-content-frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    vertically_stretchable = "off",
    top_padding=3,
    bottom_padding=4,
}

styles["fluidic-outer-content-frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    vertically_stretchable = "on",
    top_padding=0,
    bottom_padding=0,
    left_padding=0,
    right_padding=0,
}

styles["fluidic-time-scale-frame"] = {
    type = "frame_style",
    parent = "naked_frame",
    horizontally_stretchable = "on"
}

styles["fluidic-entity-preview"] =
{
  type = "empty_widget_style",
  height = 130,
  horizontally_stretchable = "on",
  vertically_stretchable = "on",
}

styles["fluidic-dark-content-frame"] = {
    type="frame_style",
    parent="frame",
    vertical_flow_style={type="vertical_flow_style", vertical_spacing=2},
    top_padding=6,--3,
    bottom_padding=4,--1,
    left_padding=12,--4,
    right_padding=12,--4,
    graphical_set=styles["subheader_frame"].graphical_set
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

styles["fluidic-timescale-radio"] = {
    type = "radiobutton_style",
    parent = "radiobutton",
    text_padding = 5
}

styles["fluidic-what-is-this"] = {
    type = "label_style",
    font_color = {1, 1, 1, 0.5}
}