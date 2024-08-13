

script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.get_player(event.player_index)
    local entity = event.entity
    if player.gui.screen["ugg_main_frame"] then
        player.gui.screen["ugg_main_frame"].destroy()
        end
    if entity == nil then
        return
    end
    if entity.name == "decider-combinator" or entity.name == "constant-combinator" or entity.name == "arithmetic-combinator"
    then
        
        local screen_element = player.gui.screen
        local main_frame= screen_element.add{type="frame", name="ugg_main_frame", caption={"ugg.hello_world"}}
        main_frame.location = {0, player.display_resolution.height / 2 }
        local content_frame = main_frame.add{type="frame", name="content_frame", direction="vertical", style="ugg_content_frame"}
        local controls_flow = content_frame.add{type="flow", name="controls_flow", direction="horizontal", style="ugg_controls_flow"}
        if global[player.index] == nil or global[player.index] ~= entity then
            controls_flow.add{type="button", name="selection_button", caption={"ugg.select"}}
            return
        end
        controls_flow.add{type="button", name="selection_button", caption={"ugg.selected"}, enable = false, ignored_by_interaction = true}
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local player = game.get_player(event.player_index)
    if player.gui.screen["ugg_main_frame"] then
        player.gui.screen["ugg_main_frame"].destroy()
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)

    if event.element.name == "selection_button" then
        global[player.index] = player.opened
        player.print("Selected: " .. player.opened.name)    
        player.gui.screen["ugg_main_frame"].destroy()
        local screen_element = player.gui.screen
        local main_frame= screen_element.add{type="frame", name="ugg_main_frame", caption={"ugg.hello_world"}}
        main_frame.location = {0, player.display_resolution.height / 2 }
        local content_frame = main_frame.add{type="frame", name="content_frame", direction="vertical", style="ugg_content_frame"}
        local controls_flow = content_frame.add{type="flow", name="controls_flow", direction="horizontal", style="ugg_controls_flow"}
        controls_flow.add{type="button", name="selection_button", caption={"ugg.selected"}, enable = false, ignored_by_interaction = true}
    end
end)


script.on_event(defines.events.on_tick, function(event)
    local red = 0
    local green = 0
    local blue = 0  
    if game.tick % 20 == 0 then
        for i, player in pairs(game.players) do
        if global[player.index] then
            local entity = global[player.index]
            if entity.valid then
                if entity.name == "constant-combinator" then
                    red = entity.get_merged_signal ({type = "virtual", name = "signal-red"} ,defines.circuit_connector_id.constant_combinator  )
                    green = entity.get_merged_signal ({type = "virtual", name = "signal-green"} ,defines.circuit_connector_id.constant_combinator  )
                    blue = entity.get_merged_signal ({type ="virtual", name = "signal-blue"} ,defines.circuit_connector_id.constant_combinator  )
                else
                    red = entity.get_merged_signal ({type = "virtual", name = "signal-red"} ,defines.circuit_connector_id.combinator_output )
                    green = entity.get_merged_signal ({type = "virtual", name = "signal-green"} ,defines.circuit_connector_id.combinator_output )
                    blue = entity.get_merged_signal ({type ="virtual", name = "signal-blue"} ,defines.circuit_connector_id.combinator_output )
                end
                red = math.min(255, math.max(red, 0))
                green = math.min(255, math.max(green, 0))
                blue = math.min(255, math.max(blue, 0))
                local color = {r = red, g = green, b = blue, a = 128}
                player.color = color
                else
                    global[player.index] = nil
                end
            end
        end
    end
end)
