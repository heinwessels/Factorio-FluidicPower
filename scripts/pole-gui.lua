local util = require("util")
local fluidic_util = require("scripts.fluidic-utils")

local pole_gui = {
    name = "fluidic-pole-gui",
    time_scales_name = "fluidic-time-scales",
    time_scales = {
        ["1m"] = defines.flow_precision_index.one_minute, 
        ["10m"] = defines.flow_precision_index.ten_minutes, 
        ["1h"] = defines.flow_precision_index.one_hour
    }
}

function pole_gui.refresh_for_player(player)
    local player_data = global.players[player.index]
    if not player_data or not player_data.pole_gui then return end
    local gui = player_data.pole_gui

    ---------------------
    -- Global statistics
    ---------------------
    local precision_index = nil
    for _, elem in pairs(gui.time_scale_frame.children) do
        if elem.type == "radiobutton" and elem.state == true then
            precision_index = pole_gui.time_scales[elem.name]
        end
    end
    if not precision_index then error("Could not find precision index!") end
    
    local fluid_statistics = player.force.fluid_production_statistics
    local produced = fluid_statistics.get_flow_count{name = "fluidic-10-kilojoules", 
        input = true, precision_index = precision_index}
    local consumed = fluid_statistics.get_flow_count{name = "fluidic-10-kilojoules",
        precision_index = precision_index}

    local multiplier = 10e3 / 60
    produced = produced * multiplier
    consumed = consumed * multiplier

    local ceiling = math.max(produced, consumed, 1)
    gui.production_bar.value = produced / ceiling
    gui.production_bar.caption = util.format_number(produced, true).."W"

    gui.consumption_bar.value = consumed / ceiling
    gui.consumption_bar.caption = util.format_number(consumed, true).."W"

    ----------------------------
    -- This fluidic pole's data
    ----------------------------
    local fluids_frame = gui.fluids_frame
    for _, child in pairs(fluids_frame.children) do child.destroy() end
    local fluidic_entity = gui.this_fluidic_entity    
    for index = 1, #fluidic_entity.fluidbox do
        local capacity = fluidic_entity.fluidbox.get_capacity(index)
        local fluid = fluidic_entity.fluidbox[index]
        local outside = fluids_frame.add{type="frame", direction="horizontal", style="naked_frame"}
        outside.add{type="sprite", sprite="fluid/"..fluid.name}
        local inside = outside.add{type="frame", direction="vertical", style="naked_frame"}
        inside.add{type="label", 
            caption={"", game.fluid_prototypes[fluid.name].localised_name, ": ", {"description.of", math.floor(fluid.amount+0.5), capacity}}}
        inside.add{type="progressbar",
            style="statistics_progressbar", value=fluid.amount/capacity}
    end

end

function pole_gui.build_for_player(pole, player)
    local main = player.gui.relative.add{name=pole_gui.name, type="frame",
        style="naked_frame", direction="vertical", anchor={
            gui=defines.relative_gui_type.electric_network_gui, 
            position=defines.relative_gui_position.left}}

    ---------------------
    -- Global statistics
    ---------------------
    local statistics = main.add{type="frame",
        style="fluidic-main-frame", direction="vertical", anchor=anchor}

    statistics.add{type="label",  caption={"fluidic-pole-gui.statistics"},
        style="frame_title", direction="vertical"}
    local content = statistics.add{type="frame", name="content", 
        direction="vertical", style="fluidic-content-frame"}
    content.add{type="label", direction="vertical",
        style="fluidic-what-is-this", caption={"fluidic-pole-gui.what-is-this-label"}}

    content.add{type="label", direction="vertical",
        style="heading_3_label", caption={"gui-electric-network.production"}}
    local production_bar = content.add{type="progressbar",
        style="fluidic-production-bar", value=1}

    content.add{type="label", direction="vertical",
        style="heading_3_label", caption={"gui-electric-network.consumption"}}
    local consumption_bar = content.add{type="progressbar",
        style="fluidic-consumption-bar", value=1}

    local time_scale_frame = content.add{type="frame", name=pole_gui.time_scales_name,
        direction="horizontal", style="fluidic-time-scale-frame"}    
    time_scale_frame.add{type="label", direction="vertical",
        caption={"fluidic-pole-gui.time-scale"}}
    for scale, _ in pairs(pole_gui.time_scales) do
        time_scale_frame.add{type="radiobutton", name=scale, direction="vertical",
            style="fluidic-timescale-radio", caption=scale, state=scale=="1m"}
    end

    ----------------------------
    -- This fluidic pole's data
    ----------------------------
    local this_pole_gui = main.add{type="frame", style="fluidic-main-frame", 
        direction="vertical", anchor=anchor}
    this_pole_gui.add{type="label", caption={"fluidic-pole-gui.this-pole-header"},
        style="frame_title", direction="vertical"}
    local pole_content = this_pole_gui.add{type="frame",
        direction="vertical", style="fluidic-content-frame"}
    pole_content.add{type="label", direction="vertical",
        caption={"fluidic-pole-gui.pole-contents"}}
    local fluids_frame = pole_content.add{type="frame", name="fluids-frame",
        style="fluidic-dark-frame", direction="vertical", anchor=anchor}
    
    
    global.players[player.index] = global.players[player.index] or { }
    global.players[player.index].pole_gui = {
        production_bar = production_bar,
        consumption_bar = consumption_bar,
        time_scale_frame = time_scale_frame,
        this_pole_gui = this_pole_gui,
        fluids_frame = fluids_frame,
        this_fluidic_entity = fluidic_util.get_fluidic_entity_from_electric(pole)
    }
end

function pole_gui.open_for_player(pole, player)
    
    -- If GUI doesn't exist yet for player then build it
    local gui = nil -- will contain the gui if it exists
    for _, child in pairs(player.gui.relative.children) do
        if child.name == pole_gui.name then
            gui = child
        end
    end
    if not gui then
        gui = pole_gui.build_for_player(pole, player)
    end
end

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    if event.element.parent.name == pole_gui.time_scales_name then
        local elm = event.element
        if elm.type == "radiobutton" then
          if elm.state == false then --[[can't deactivate already active radio button]]
            elm.state = true
          else
            for _, child in pairs(elm.parent.children) do
              if child.type == "radiobutton" then
                child.state = false
              end
            end
            elm.state = true --[[turn it back on]]
          end
        end
      end
end)

return pole_gui