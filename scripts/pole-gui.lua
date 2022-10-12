local util = require("util")

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
end

function pole_gui.build_for_player(pole, player)
    local main = player.gui.relative.add{name=pole_gui.name, 
        type="frame",  direction="vertical", anchor = {
            gui=defines.relative_gui_type.electric_network_gui, 
            position=defines.relative_gui_position.left
        }
    }
    main.style.size = {300, 500}

    local title = main.add{type="label",  caption={"fluidic-pole-gui.header"},
        style="frame_title", direction="vertical"}
    local content = main.add{type="frame", name="content", 
        direction="vertical", style="fluidic-content-frame"}

    local production_label = content.add{type="label", direction="vertical",
        style="heading_3_label", caption={"gui-electric-network.production"}}
    local production_bar = content.add{type="progressbar",
        style="fluidic-production-bar", value=1}

    local consumption_label = content.add{type="label", direction="vertical",
        style="heading_3_label", caption={"gui-electric-network.consumption"}}
    local consumption_bar = content.add{type="progressbar",
        style="fluidic-consumption-bar", value=1}

    local time_scale_frame = content.add{type="frame", name=pole_gui.time_scales_name,
        direction="horizontal", style="fluidic-time-scale-frame"}    
    local time_scale_label = time_scale_frame.add{type="label", direction="vertical",
        caption={"fluidic-pole-gui.time-scale"}}
    for scale, _ in pairs(pole_gui.time_scales) do
        time_scale_frame.add{type="radiobutton", name=scale, direction="vertical",
            style="fluidic-timescale-radio", caption=scale, state=scale=="1m"}
    end


    global.players[player.index] = global.players[player.index] or { }
    global.players[player.index].pole_gui = {
        production_bar = production_bar,
        consumption_bar = consumption_bar,
        time_scale_frame = time_scale_frame
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