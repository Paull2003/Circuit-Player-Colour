script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.get_player(event.player_index)
    local entity = event.entity
    if player.gui.screen["selector_main_frame"] then
        player.gui.screen["selector_main_frame"].destroy()
    end
    for i, player in pairs(game.players) do
        if storage[player.index] == nil then
            storage[player.index] = {}
        end
    end
    if entity == nil then
        return
    end
    if entity.name == "decider-combinator" or entity.name == "constant-combinator" or entity.name == "arithmetic-combinator" or entity.name == "selector-combinator"
    then
        local screen_element = player.gui.screen
        local main_frame = screen_element.add { type = "frame", name = "selector_main_frame", caption = { "selector.Window_Title" } }
        main_frame.location = { 0, player.display_resolution.height / 2 }
        local content_frame = main_frame.add { type = "frame", name = "content_frame", direction = "vertical", style = "selector_content_frame" }
        local controls_flow = content_frame.add { type = "flow", name = "controls_flow", direction = "horizontal", style = "selector_controls_flow" }
        if storage[player.index]["entity"] == nil or storage[player.index]["entity"] ~= entity then
            controls_flow.add { type = "button", name = "selection_button_green", caption = { "selector.select_green" } }
            controls_flow.add { type = "button", name = "selection_button_red", caption = { "selector.select_red" } }

            return
        elseif storage[player.index]["entity"] == entity and storage[player.index]["network"] == "green" then
            controls_flow.add { type = "button", name = "selection_button_green", caption = { "selector.selected_green" }, enable = false, ignored_by_interaction = true }
            controls_flow.add { type = "button", name = "selection_button_red", caption = { "selector.select_red" } }
            return
        elseif storage[player.index]["entity"] == entity and storage[player.index]["network"] == "red" then
            controls_flow.add { type = "button", name = "selection_button_green", caption = { "selector.select_green" } }
            controls_flow.add { type = "button", name = "selection_button_red", caption = { "selector.selected_red" }, enable = false, ignored_by_interaction = true }
            return
        end
        controls_flow.add { type = "button", name = "selection_button_green", caption = { "selector.select_green" } }
        controls_flow.add { type = "button", name = "selection_button_red", caption = { "selector.select_red" } }
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local player = game.get_player(event.player_index)
    if player.gui.screen["selector_main_frame"] then
        player.gui.screen["selector_main_frame"].destroy()
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)

    if event.element.name == "selection_button_red" then
        storage[player.index]["entity"] = player.opened
        storage[player.index]["network"] = "red"
        player.print("Selected: " .. player.opened.name .. " " .. storage[player.index]["network"])
        player.gui.screen["selector_main_frame"].destroy()
        local screen_element = player.gui.screen
        local main_frame = screen_element.add { type = "frame", name = "selector_main_frame", caption = { "selector.Window_Title" } }
        main_frame.location = { 0, player.display_resolution.height / 2 }
        local content_frame = main_frame.add { type = "frame", name = "content_frame", direction = "vertical", style = "selector_content_frame" }
        local controls_flow = content_frame.add { type = "flow", name = "controls_flow", direction = "horizontal", style = "selector_controls_flow" }
        controls_flow.add { type = "button", name = "selection_button_green", caption = { "selector.select_green" } }
        controls_flow.add { type = "button", name = "selection_button_red", caption = { "selector.selected_red" }, enable = false, ignored_by_interaction = true }
        return
    elseif event.element.name == "selection_button_green" then
        storage[player.index]["entity"] = player.opened
        storage[player.index]["network"] = "green"
        player.print("Selected: " .. player.opened.name .. " " .. storage[player.index]["network"])
        player.gui.screen["selector_main_frame"].destroy()
        local screen_element = player.gui.screen
        local main_frame = screen_element.add { type = "frame", name = "selector_main_frame", caption = { "selector.Window_Title" } }
        main_frame.location = { 0, player.display_resolution.height / 2 }
        local content_frame = main_frame.add { type = "frame", name = "content_frame", direction = "vertical", style = "selector_content_frame" }
        local controls_flow = content_frame.add { type = "flow", name = "controls_flow", direction = "horizontal", style = "selector_controls_flow" }
        controls_flow.add { type = "button", name = "selection_button_green", caption = { "selector.selected_green" }, enable = false, ignored_by_interaction = true }
        controls_flow.add { type = "button", name = "selection_button_red", caption = { "selector.select_red" } }
        return
    end
end)


script.on_event(defines.events.on_tick, function(event)
    for i, player in pairs(game.players) do
        if storage[player.index] == nil then
            storage[player.index] = {}
        end
    end
    local red = 0
    local green = 0
    local blue = 0
    if game.tick % 20 == 0 then
        for i, player in pairs(game.players) do
            if storage[player.index]["entity"] then
                local entity = storage[player.index]["entity"]
                if entity.valid then
                    if storage[player.index]["network"] == "red" then
                        if entity.name == "constant-combinator" then
                            red = entity.get_signal({ type = "virtual", name = "signal-red" },
                                defines.wire_connector_id.circuit_red)
                            green = entity.get_signal({ type = "virtual", name = "signal-green" },
                                defines.wire_connector_id.circuit_red)
                            blue = entity.get_signal({ type = "virtual", name = "signal-blue" },
                                defines.wire_connector_id.circuit_red)
                        else
                            red = entity.get_signal({ type = "virtual", name = "signal-red" },
                                defines.wire_connector_id.combinator_output_red)
                            green = entity.get_signal({ type = "virtual", name = "signal-green" },
                                defines.wire_connector_id.combinator_output_red)
                            blue = entity.get_signal({ type = "virtual", name = "signal-blue" },
                                defines.wire_connector_id.combinator_output_red)
                        end
                        red = math.min(255, math.max(red, 0))
                        green = math.min(255, math.max(green, 0))
                        blue = math.min(255, math.max(blue, 0))
                        local color = { r = red, g = green, b = blue, a = 128 }
                        player.color = color
                    elseif storage[player.index]["network"] == "green" then
                        if entity.name == "constant-combinator" then
                            red = entity.get_signal({ type = "virtual", name = "signal-red" },
                                defines.wire_connector_id.circuit_green)
                            green = entity.get_signal({ type = "virtual", name = "signal-green" },
                                defines.wire_connector_id.circuit_green)
                            blue = entity.get_signal({ type = "virtual", name = "signal-blue" },
                                defines.wire_connector_id.circuit_green)
                        else
                            red = entity.get_signal({ type = "virtual", name = "signal-red" },
                                defines.wire_connector_id.combinator_output_green)
                            green = entity.get_signal({ type = "virtual", name = "signal-green" },
                                defines.wire_connector_id.combinator_output_green)
                            blue = entity.get_signal({ type = "virtual", name = "signal-blue" },
                                defines.wire_connector_id.combinator_output_green)
                        end
                        red = math.min(255, math.max(red, 0))
                        green = math.min(255, math.max(green, 0))
                        blue = math.min(255, math.max(blue, 0))
                        local color = { r = red, g = green, b = blue, a = 128 }
                        player.color = color
                    end
                else
                    storage[player.index]["entity"] = nil
                end
            end
        end 
    end
end)
