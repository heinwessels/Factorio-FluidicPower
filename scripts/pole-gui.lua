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

local function fluid_to_energy(amount, fluid_type)
    if not fluid_type or fluid_type == "fluidic-10-kilojoules" then return amount * 10e3 end
    if fluid_type == "fluidic-megajoules" then return amount * 1e6 end
    if fluid_type == "fluidic-100-megajoules" then return amount * 100e6 end
    error("Bad fluid type: "..fluid_type)
end

function pole_gui.refresh_statistics_for_player(gui_data, player)
    local precision_index = nil
    for _, elem in pairs(gui_data.time_scale_frame.children) do
        if elem.type == "radiobutton" and elem.state == true then
            precision_index = pole_gui.time_scales[elem.name]
        end
    end
    if not precision_index then error("Could not find precision index!") end

    local fluid_statistics = player.force.fluid_production_statistics
    local produced = fluid_to_energy(fluid_statistics.get_flow_count{name = "fluidic-10-kilojoules", 
        input = true, precision_index = precision_index}) / 60
    local consumed = fluid_to_energy(fluid_statistics.get_flow_count{name = "fluidic-10-kilojoules",
        precision_index = precision_index}) / 60

    local ceiling = math.max(produced, consumed, 1)
    gui_data.production_bar.value = produced / ceiling
    gui_data.production_bar.caption = fluidic_util.format_number(produced, true).."W"

    gui_data.consumption_bar.value = consumed / ceiling
    gui_data.consumption_bar.caption = fluidic_util.format_number(consumed, true).."W"
end

function pole_gui.refresh_this_pole_for_player(gui_data, player)
    local fluidic_entity = gui_data.entities.fluidic

    gui_data.visible = fluidic_entity.valid
    if not fluidic_entity.valid then return end

    local capacity = fluidic_entity.fluidbox.get_capacity(1)
    local fluid = fluidic_entity.fluidbox[1] or {name=nil, amount=0}

    if fluid.name then
        if fluid.name ~= gui_data.fluid_last then
            gui_data.fluid_sprite.sprite = "fluid/"..fluid.name
            gui_data.fluid_sprite.tooltip = {
                "fluidic-pole-gui.fluid-sprite-tooltip", game.fluid_prototypes[fluid.name].localised_name}
            gui_data.fluid_last = fluid.name -- ensure this is only done once
        end
        gui_data.fluid_descr.caption = {"fluidic-pole-gui.fluid-name", 
            fluidic_util.format_number(fluid_to_energy(fluid.amount, fluid.name), true).."J"}
        gui_data.fluid_bar.value = fluid.amount / capacity
    else
        if gui_data.fluid_last then
            gui_data.fluid_sprite.sprite = "fluid/fluidic-10-kilojoules"
            gui_data.fluid_descr.caption = {"fluidic-pole-gui.fluid-name", "0J"}
            gui_data.fluid_bar.value = 0
            gui_data.fluid_last = nil -- ensure this is only done once
        end
    end

    -- Only check for bad fluid connections every second
    if game.tick % 120 ~= 0 then return end
    local conflicts = {}    
    for _, neighbour in pairs(fluidic_util.get_fluid_neighbours(fluidic_entity)) do
        local fluids = fluidic_util.is_connection_fluids_mixed(fluidic_entity, neighbour)
        if fluids then table.insert(conflicts, {neighbour, fluids}) end
    end
    if next(conflicts) then
        gui_data.conflict_frame.visible = true
        local compound_tooptip = {"", {"fluidic-pole-gui.conflict-tooltip-description"}}
        for _, conflict in pairs(conflicts) do
            local neighbour, fluids = conflict[1], conflict[2]
            local fluid = fluids[2]            
            table.insert(compound_tooptip, {"fluidic-pole-gui.conflict-tooltip-entry",
                neighbour.name,
                neighbour.prototype.localised_name,
                fluid.name,
                game.fluid_prototypes[fluid.name].localised_name
            })
        end
        gui_data.conflict_tooltip_element.tooltip = compound_tooptip
    else
        gui_data.conflict_frame.visible = false
    end
end

function pole_gui.refresh_for_player(player)
    if player.opened_gui_type ~= defines.gui_type.entity then return end
    local looking_at = player.opened
    if not looking_at or not looking_at.type or looking_at.type ~= "electric-pole" then return end

    local player_data = global.players[player.index]
    if not player_data or not player_data.gui_data then return end
    local gui_data = player_data.gui_data

    pole_gui.refresh_statistics_for_player(gui_data.statistics_gui, player)
    pole_gui.refresh_this_pole_for_player(gui_data.pole_gui, player)
end

function pole_gui.build_statistics_for_player(gui_data, player, handle)
    local main = handle.add{type="frame",
        style="fluidic-main-frame", direction="vertical", anchor=anchor}
    main.add{type="label",  caption={"fluidic-pole-gui.statistics"},
        style="frame_title", direction="vertical"}
    local outer = main.add{type="frame",
        direction="vertical", style="fluidic-outer-content-frame"}
    
    local what_frame = outer.add{type="frame", name="content", 
        direction="vertical", style="fluidic-content-frame"}
    what_frame.add{type="label", style="fluidic-what-is-this", 
        caption={"fluidic-pole-gui.what-is-this-label"}, 
        tooltip={"fluidic-pole-gui.what-is-this-tooltip"}}

    local power_frame = outer.add{type="frame", name="fluids-frame",
        style="fluidic-dark-content-frame", direction="vertical", anchor=anchor}
        power_frame.add{type="label", direction="vertical",
        style="heading_3_label", caption={"gui-electric-network.production"}}
    local production_bar = power_frame.add{type="progressbar",
        style="fluidic-production-bar", value=1}

    power_frame.add{type="label", direction="vertical",
        style="heading_3_label", caption={"gui-electric-network.consumption"}}
    local consumption_bar = power_frame.add{type="progressbar",
        style="fluidic-consumption-bar", value=1}

    local time_scale_frame = power_frame.add{type="frame", name=pole_gui.time_scales_name,
        direction="horizontal", style="fluidic-time-scale-frame"}    
    time_scale_frame.add{type="label", direction="vertical",
        caption={"fluidic-pole-gui.time-scale"}}
    for scale, _ in pairs(pole_gui.time_scales) do
        time_scale_frame.add{type="radiobutton", name=scale, direction="vertical",
            style="fluidic-timescale-radio", caption=scale, state=scale=="10m"}
    end

    gui_data.statistics_gui = {
        production_bar = production_bar,
        consumption_bar = consumption_bar,
        time_scale_frame = time_scale_frame,
    }
end

function pole_gui.build_this_for_player(gui_data, player, anchor)
    local handle = anchor.add{type="frame", style="fluidic-main-frame", 
        direction="vertical"}
    local title = handle.add{type="label", caption={"This is a pole yea"},
        style="frame_title", direction="vertical"}
    local outer = handle.add{type="frame",
        direction="vertical", style="fluidic-outer-content-frame"}

    local entity_preview = outer.add{type="entity-preview", 
        style="fluidic-entity-preview"}
    local fluids_frame = outer.add{type="frame", name="fluids-frame",
        style="fluidic-dark-content-frame", direction="vertical"}

    local outside = fluids_frame.add{type="frame", direction="horizontal", style="naked_frame"}
    local fluid_sprite = outside.add{type="sprite", sprite="fluid/fluidic-10-kilojoules"} -- default
    local inside = outside.add{type="frame", direction="vertical", style="naked_frame"}
    local fluid_descr = inside.add{type="label", 
        caption={"",
            {"fluidic-pole-gui.fluid-name", {"fluidic-pole-gui.fluid-name-nothing"}}, "0J"}}
    local fluid_bar = inside.add{type="progressbar", style="statistics_progressbar", value=0}
    
    local conflict_frame = outer.add{type="frame",
        style="fluidic-red-content-frame"}
    local red_flow = conflict_frame.add{type="flow"}
    local conflict_label = red_flow.add{type="label", style="heading_2_label",
        caption={"fluidic-pole-gui.conflict-detected"}}

    gui_data.pole_gui = {
        handle = handle,
        title = title,
        entity_preview = entity_preview,
        
        fluid_sprite = fluid_sprite,
        fluid_descr = fluid_descr,
        fluid_bar = fluid_bar,
        fluid_last = nil,
        
        conflict_frame = conflict_frame,
        conflict_tooltip_element = conflict_label,
    }    
end

function pole_gui.build_for_player(gui_data, player)
    local main = player.gui.relative.add{name=pole_gui.name, type="frame",
        style="naked_frame", direction="vertical", anchor={
            gui=defines.relative_gui_type.electric_network_gui, 
            position=defines.relative_gui_position.left}}

    pole_gui.build_statistics_for_player(gui_data, player, main)
    pole_gui.build_this_for_player(gui_data, player, main)
end

function pole_gui.open_for_player(pole, player)
    if pole.type ~= "electric-pole" then return end
    if string.sub(pole.name, 1, 7) ~= "fluidic" then return end
    
    -- Find any existing data on this GUI
    local exist = true
    local gui_data = global.players[player.index] and global.players[player.index].gui_data or nil
    if not gui_data then
        global.players[player.index] = global.players[player.index] or { }
        global.players[player.index].gui_data = { }
        gui_data = global.players[player.index].gui_data
        exist = false
    end

    -- If the Gui doesn't exist yet, create it
    if not exist then
        pole_gui.build_for_player(gui_data, player)
    end

    -- Update the gui to point towards the correct
    gui_data.pole_gui.entity_preview.entity = pole
    gui_data.pole_gui.conflict_frame.visible = false
    gui_data.pole_gui.title.caption = pole.prototype.localised_name
    gui_data.pole_gui.entities = {
        electric = pole,
        fluidic = fluidic_util.get_fluidic_entity_from_electric(pole),
    }

    -- Refresh the pole GUI, otherwise there's a flash of the old data
    pole_gui.refresh_this_pole_for_player(gui_data.pole_gui, player)
end

function pole_gui.destroy_for_player(player)
    for _, child in pairs(player.gui.relative.children) do
        if child.name == pole_gui.name then child.destroy() end
    end
    global.players[player.index].gui_data = { }
end

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    if event.element.parent.name == pole_gui.time_scales_name then
        local elm = event.element
        if elm.type == "radiobutton" then
            if elm.state == false then --[[can't deactivate already active radio button]]
                elm.state = true
            else
                for _, child in pairs(elm.parent.children) do
                    if child.type == "radiobutton" then child.state = false end
                end
                elm.state = true --[[turn it back on]]
            end
        end
    end
end)

return pole_gui