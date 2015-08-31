-- Allow homebrew packages for luarocks
local homebrew = string.format("%s/dev/homebrew", os.getenv("HOME"))
package.path  = package.path  .. string.format(";%s/share/lua/5.2/?.lua", homebrew)
package.cpath = package.cpath .. string.format(";%s/lib/lua/5.2/?.so", homebrew)

require "os"
local json = require("json")

-- Global hotkey modifiers
unmodal = {"shift", "alt"}
modal = {"alt"}

--------------------
--- App focusing ---
--------------------

-- Windows with letter bindings
apps = {
 ["Firefox"] = "f",
 ["MacVim"] = "v",
 ["Slack"] = "s",
 ["Messages"] = "m",
 ["Mathematica"] = "w",
 ["Pandora"] = "p",
 ["Google Chrome"] = "g",
 ["Colloquy"] = "y",
 ["Anki"] = "a",
 ["iTerm2"] = "i",
}

function focus_app(name)
    -- Get the app however we can.
    local app = hs.appfinder.appFromName(name)
    if app == nil then
        app = hs.appfinder.appFromWindowTitle(name)
    end
    if app == nil then
        app = hs.appfinder.appFromWindowTitlePattern(name)
    end

    if app == nil then
        hs.alert.show("Could not find " .. name, 1)
    else
        app:activate(true)
    end
    return app
end

-- Bind windows to hotkeys
for name, key in pairs(apps) do
    hs.hotkey.bind(unmodal, key, function() focus_app(name) end)
end

--------------------
--------------------
--------------------

-----------------------
--- Window Movement ---
-----------------------

-- Set up modal bindings.
local mode = hs.hotkey.modal.new(modal, "escape")
mode:bind({}, 'escape', function() mode:exit() end)

-- Set up badge for modal keybinding.
local screen = hs.screen.allScreens()[1]
local badge_size = 800
local badge_rect = hs.geometry.rect(screen:currentMode().w / 2 - badge_size / 2, screen:currentMode().h / 2 - badge_size / 2, badge_size, badge_size)
local badge = hs.drawing.image(badge_rect, "~/.hammerspoon/vortex.png")
badge:bringToFront(true)

-- Show badge when in mode.
function mode:entered() badge:show() end
function mode:exited()  badge:hide() end

-- Control whether we're in 3x3 or 4x3 mode.
local quarters = false
mode:bind({}, "1", function() quarters = false end)
mode:bind({}, "2", function() quarters = true end)

-- Remember whether we're setting the top left or bottom right.
local topLeft = nil

-- Points that keys represent
key_points = {
    -- quarters = true
    [false] = {
        q = {x = 0   , y = 0}   ,
        w = {x = 1/3 , y = 0}   ,
        e = {x = 2/3 , y = 0}   ,
        a = {x = 0   , y = 1/3} ,
        s = {x = 1/3 , y = 1/3} ,
        d = {x = 2/3 , y = 1/3} ,
        z = {x = 0   , y = 2/3} ,
        x = {x = 1/3 , y = 2/3} ,
        c = {x = 2/3 , y = 2/3} ,
    },
    -- quarters = false
    [true] = {
        q = {x = 0   , y = 0}   ,
        w = {x = 1/4 , y = 0}   ,
        e = {x = 2/4 , y = 0}   ,
        r = {x = 3/4 , y = 0}   ,
        a = {x = 0   , y = 1/3} ,
        s = {x = 1/4 , y = 1/3} ,
        d = {x = 2/4 , y = 1/3} ,
        f = {x = 3/4 , y = 1/3} ,
        z = {x = 0   , y = 2/3} ,
        x = {x = 1/4 , y = 2/3} ,
        c = {x = 2/4 , y = 2/3} ,
        v = {x = 3/4 , y = 2/3} ,
    },
}

function rect_from_corners(top_left, bottom_right)
    if top_left.x <= bottom_right.x and top_left.y <= bottom_right.y then
        if quarters then
            return {x = top_left.x, y = top_left.y, w = bottom_right.x - top_left.x + 1/4, h = bottom_right.y - top_left.y + 1/3}
        else
            return {x = top_left.x, y = top_left.y, w = bottom_right.x - top_left.x + 1/3, h = bottom_right.y - top_left.y + 1/3}
        end
    else
        return nil
    end
end

locations = "qwerasdfzxcv"
for i = 1, locations:len() do
    local char = locations:sub(i, i)
    mode:bind({"ctrl"}, char, function()
        point = key_points[quarters][char]
        if topLeft == nil then
            topLeft = point
        else
            local win = hs.window.focusedWindow()
            local rect = rect_from_corners(topLeft, point)
            if rect ~= nil then
                win:setFrame(unit_to_screen_rect(rect), 0)
            end

            topLeft = nil
        end
    end)
end

-- Scale a unit rect to a screen rect.
function unit_to_screen_rect(frame)
    -- Get current screen dimensions
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local screenMode = screen:currentMode()
    local w = screenMode.w
    local h = screenMode.h
    local s = screen:frame()
    return {x = frame.x * w + s.x, w = frame.w * w + s.y, y = frame.y * h, h = frame.h * h}
end

-- Directions for windows. More standard movement!
function direct(key, unit) 
    mode:bind({}, key, function()
        local win = hs.window.focusedWindow()
        win:setFrame(unit_to_screen_rect(unit), 0)
    end)
end

directions = {
    a = {x = 0   , y = 0   , w = 0.5 , h = 1}   ,
    d = {x = 0.5 , y = 0   , w = 0.5 , h = 1}   ,
    w = {x = 0   , y = 0   , w = 1   , h = 0.5} ,
    s = {x = 0   , y = 0.5 , w = 1   , h = 0.5} ,

    q = {x = 0   , y = 0   , w = 0.5 , h = 0.5} ,
    e = {x = 0.5 , y = 0   , w = 0.5 , h = 0.5} ,
    z = {x = 0   , y = 0.5 , w = 0.5 , h = 0.5} ,
    c = {x = 0.5 , y = 0.5 , w = 0.5 , h = 0.5} ,

    x = {x = 0   , y = 0   , w = 1   , h = 1}   ,
}

for key, rect in pairs(directions) do direct(key, rect) end
mode:bind({"shift"}, "x", function() 
    local win = hs.window.focusedWindow()
    win:toggleFullScreen()
end)

mode:bind({}, "left", function() 
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local newScreen = screen:previous()
    win:moveToScreen(newScreen, 0)
end)
mode:bind({}, "right", function() 
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local newScreen = screen:next()
    win:moveToScreen(newScreen, 0)
end)

function window_id_comparator(win1, win2)
    return win1:id() < win2:id()
end

-- Switch which window is focused by using h and l in command mode.
mode:bind({}, "h", function()
    local win = hs.window.focusedWindow()
    local wins = win:application():allWindows()
    table.sort(wins, window_id_comparator)

    -- Does not apply when only one window.
    if #wins == 1 then
        return
    end

    local target = nil
    for i, w in pairs(wins) do
        if win:id() == w:id() then
            if i == 1 then
                target = wins[#wins]
            else
                target = wins[i - 1]
            end
        end
    end

    target:focus()
end)
mode:bind({}, "l", function()
    local win = hs.window.focusedWindow()
    local wins = win:application():allWindows()
    table.sort(wins, window_id_comparator)

    -- Does not apply when only one window.
    if #wins == 1 then
        return
    end

    local target = nil
    for i, w in pairs(wins) do
        if win:id() == w:id() then
            if i == #wins then
                target = wins[1]
            else
                target = wins[i + 1]
            end
        end
    end

    target:focus()
end)

-----------------------
-----------------------
-----------------------

--------------------
--- Tmux Control ---
--------------------

-- Create tmux mode
local tmux_mode = hs.hotkey.modal.new({"shift"}, "escape")
tmux_mode:bind({}, 'escape', function() tmux_mode:exit() end)

-- Set up tmux badge
local tmux_badge = hs.drawing.image(badge_rect, "~/.hammerspoon/vortex2.png")
tmux_badge:bringToFront(true)

-- Tmux mode switching from global mode
function tmux_mode:entered()
    tmux_badge:show()
    focus_app("iTerm2")
end
function tmux_mode:exited()  tmux_badge:hide() end
mode:bind({}, "t", function()
    -- Avoid flash
    tmux_badge:show()

    -- Must exit mode before next mode can be activated
    mode:exit()

    tmux_mode:enter()
end)

-- Create Environment
home = os.getenv("HOME")
tmux_path = home .. "/dev/homebrew/bin/tmux"

-- Read variables from tmux using display-message
function tmux_read_format(fmt)
    local handle = io.popen(tmux_path .. " display-message -p '" .. fmt .. "'")
    local out = handle:read("*a")
    handle:close()
    return out
end

function tmux(cmd)
    local cwd_out = tmux_read_format("#{pane_current_path}")
    cwd_out = cwd_out:gsub("%s+$", "")

    local cmd_out = tmux_read_format(cmd)
    cmd_out = cmd_out:gsub("%s+$", "")

    local command = "env -i TMPDIR=" .. os.getenv("TMPDIR") .. " PWD=" .. cwd_out .. " " .. tmux_path .. " " .. cmd_out

    print(command)
    local handle = io.popen(command)
    local out = handle:read("*a")
    handle:close()
    return out
end


function tmux_bind(mod, key, cmd)
    tmux_mode:bind(mod, key, function() tmux(cmd) end)
end

tmux_bind({}, "g", "split-window -v -c #{pane_current_path} -t #I.")
tmux_bind({}, "v", "split-window -h -c #{pane_current_path} -t #I.")
tmux_bind({}, "h", "select-pane -L -t \\$#S")
tmux_bind({}, "j", "select-pane -D -t \\$#S")
tmux_bind({}, "k", "select-pane -U -t \\$#S")
tmux_bind({}, "l", "select-pane -R -t \\$#S")
tmux_bind({}, "c", "new-window -a -c #{pane_current_path} -t #S:#I")
tmux_bind({}, "n", "next-window -t \\$#S")
tmux_bind({}, "p", "previous-window -t \\$#S")
tmux_bind({}, "x", "kill-pane -t #I.")
tmux_bind({"ctrl"}, "h", "resize-pane -L -t \\$#S 8")
tmux_bind({"ctrl"}, "j", "resize-pane -D -t \\$#S 4")
tmux_bind({"ctrl"}, "k", "resize-pane -U -t \\$#S 4")
tmux_bind({"ctrl"}, "l", "resize-pane -R -t \\$#S 8")

tmux_mode:bind({}, "t", function()
    local buffer = tmux("show-buffer")

    local handle = io.popen("pbcopy", "w")
    handle:write(buffer)
    handle:close()

    tmux_mode:exit()
end)

-------------------
-------------------
-------------------

-------------------
-- View control ---
-------------------

-- View mode state
local view_name = nil -- The view to create or summon (one letter name)
local view_apps = {}  -- Apps in the current view and their window unit rects.

-- Where to store the layouts.
layout_file = home .. "/.hammerspoon.layouts"

-- Read all the layouts from our layout file.
function read_layouts()
    local handle = io.open(layout_file, "r")
    if handle == nil then
        return {}
    else
        local data = handle:read("*a")
        handle:close()
        local layouts = json.decode(data)
        if layouts == nil then
            return {}
        else
            return layouts
        end
    end
end

-- Write layouts to the layout file.
function write_layouts(layouts)
    local handle = io.open(layout_file, "w")
    handle:write(json.encode(layouts))
    handle:close()
end

-- Add a layout to the layout file.
function store_layout(name, apps) 
    local layouts = read_layouts()
    layouts[name] = apps
    write_layouts(layouts)
end

-- Load a layout from the layout file and move windows to fit it.
function summon_layout(name)
    local layouts = read_layouts()
    local layout = layouts[name]

    if layout ~= nil then
        -- Get current screen dimensions
        local w = hs.screen.mainScreen():currentMode().w
        local h = hs.screen.mainScreen():currentMode().h

        for app_name, rects in pairs(layout) do
            local app = focus_app(app_name)
            if app ~= nil then
                local wins = app:allWindows()
                for i, win in pairs(wins) do
                    local rect = rects[i]
                    if rect ~= nil then
                        win:setFrame({
                            x = rect["x"] * w,
                            y = rect["y"] * h,
                            w = rect["w"] * w,
                            h = rect["h"] * h,
                        }, 0)
                    end
                end
            end
        end
    end
end

-- Create view control and auxiliary modes
local view_mode = hs.hotkey.modal.new(nil, nil)
view_mode:bind({}, 'escape', function()
    view_mode:exit()

    view_name = nil
    view_apps = {}
end)

local view_mode_aux = hs.hotkey.modal.new(nil, nil)
view_mode_aux:bind({}, 'escape', function() view_mode_aux:exit() end)
view_mode_aux:bind({}, 'return', function() 
    store_layout(view_name, view_apps)
    view_mode_aux:exit()
end)

-- Set up view mode badge
local view_badge = hs.drawing.image(badge_rect, "~/.hammerspoon/vortex3.png")
view_badge:bringToFront(true)

-- View control mode switching from global mode
function view_mode:entered() view_badge:show() end
function view_mode:exited()  view_badge:hide() end
function view_mode_aux:exited()
    view_name = nil
    view_apps = {}
end
mode:bind({}, "v", function() 
    mode:exit() -- Must happen before next mode is entered
    view_mode:enter()
end)

function make_view(char)
    view_name = char
    view_mode:exit()
    view_mode_aux:enter()
end

-- Start making a view after entering view mode by pressing the name of the new view.
view_alphabet = "abcdefghijklmnopqrstuvwxyz"
for i = 1, view_alphabet:len() do
    local char = view_alphabet:sub(i, i)
    view_mode:bind({}, char, function() make_view(char) end)
end

-- Summon a view by using the Shift + View Name in command mode.
for i = 1, view_alphabet:len() do
    local char = view_alphabet:sub(i, i)
    mode:bind({"shift"}, char, function()
        summon_layout(char)
        mode:exit()
    end)
end

function report_focus(name, units)
    view_apps[name] = units
end

for name, key in pairs(apps) do
    view_mode_aux:bind({}, key, function()
        local app = focus_app(name)
        if app == nil then return end

        -- Collect unit rects for this app's windows
        local rects = {}
        for i, win in pairs(app:allWindows()) do
            local frame = win:frame()
            local scaled = unit_to_screen_rect(frame)
            table.insert(rects, scaled)
        end

        report_focus(name, rects)
    end)
end
