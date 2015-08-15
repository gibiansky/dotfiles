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
 ["iTerm"] = "i",
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

-- Directions for windows.
function direct(key, fun) 
    mode:bind({}, key, function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local screenMode = screen:currentMode()
        local w = screenMode.w
        local h = screenMode.h
        win:setFrame(fun(w, h), 0)
    end)
end

directions = {
    a = function(w, h) return {x = 0, y = 0, w = w/2, h = h} end,
    d = function(w, h) return {x = w/2, y = 0, w = w/2, h = h} end,
    w = function(w, h) return {x = 0, y = 0, w = w, h = h/2} end,
    s = function(w, h) return {x = 0, y = h/2, w = w, h = h/2} end,

    q = function(w, h) return {x = 0, y = 0, w = w/2, h = h/2} end,
    e = function(w, h) return {x = w/2, y = 0, w = w/2, h = h/2} end,
    z = function(w, h) return {x = 0, y = h/2, w = w/2, h = h/2} end,
    c = function(w, h) return {x = w/2, y = h/2, w = w/2, h = h/2} end,

    x = function(w, h) return {x = 0, y = 0, w = w, h = h} end,
}

for key, fun in pairs(directions) do direct(key, fun) end
mode:bind({"shift"}, "x", function() 
    local win = hs.window.focusedWindow()
    win:toggleFullScreen()
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
local tmux_mode = hs.hotkey.modal.new(nil, nil)
tmux_mode:bind({}, 'escape', function() tmux_mode:exit() end)

-- Set up tmux badge
local tmux_badge = hs.drawing.image(badge_rect, "~/.hammerspoon/vortex2.png")
tmux_badge:bringToFront(true)

-- Tmux mode switching from global mode
function tmux_mode:entered()
    focus_app("iTerm")
end
function tmux_mode:exited()  tmux_badge:hide() end
mode:bind({}, "t", function()
    -- Avoid flash
    tmux_badge:show()

    -- Must exit mode before next mode can be activated
    mode:exit()

    tmux_mode:enter()
    tmux_badge:show()
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

function tmux(fun, target)
    -- Get target name, whatever it is, and current directory
    local target_out = tmux_read_format(target)
    local cwd_out = tmux_read_format("#{pane_current_path}")
    cwd_out = cwd_out:gsub("%s+", "")

    local command = "env -i TMPDIR=" .. os.getenv("TMPDIR") .. " PWD=" .. cwd_out .. " " .. tmux_path .. " " .. fun() .. " -t " .. target_out
    os.execute(command)
end


function tmux_bind(key, cmd, target)
    tmux_mode:bind({}, key, function() tmux(function() return cmd end, target) end)
end

-- Lazy creation of commands
function tmux_bind_fun(key, fun, target)
    tmux_mode:bind({}, key, function() tmux(fun, target) end)
end

tmux_bind_fun("h", function()
    local dir = tmux_read_format("#{pane_current_path}")
    return "split-window -v -c " .. dir
end, "#I")
tmux_bind_fun("v", function()
    local dir = tmux_read_format("#{pane_current_path}")
    return "split-window -h -c " .. dir
end, "#I")
tmux_bind("h", "select-pane -L", "\\$#S")
tmux_bind("j", "select-pane -D", "\\$#S")
tmux_bind("k", "select-pane -U", "\\$#S")
tmux_bind("l", "select-pane -R", "\\$#S")
tmux_bind_fun("c", function()
    local dir = tmux_read_format("#{pane_current_path}")
    return "new-window -c " .. dir
end, "#I")
tmux_bind("n", "next-window", "\\$#S")
tmux_bind("p", "previous-window", "\\$#S")

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

        -- Get current screen dimensions
        local w = hs.screen.mainScreen():currentMode().w
        local h = hs.screen.mainScreen():currentMode().h

        -- Collect unit rects for this app's windows
        local rects = {}
        for i, win in pairs(app:allWindows()) do
            local frame = win:frame()
            local scaled = {x = frame["x"] / w, w = frame["w"] / w, y = frame["y"] / h, h = frame["h"] / h}
            table.insert(rects, scaled)
        end

        report_focus(name, rects)
    end)
end
