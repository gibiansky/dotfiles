-- Allow homebrew packages for luarocks
local homebrew = string.format("%s/dev/homebrew", os.getenv("HOME"))
package.path  = package.path  .. string.format(";%s/share/lua/5.2/?.lua", homebrew)
package.cpath = package.cpath .. string.format(";%s/lib/lua/5.2/?.so", homebrew)

require "os"

-- Global hotkey modifiers
unmodal = {"shift", "alt"}
modal = {"alt"}

--------------------
--- App focusing ---
--------------------

-- Windows with letter bindings
apps = {
 ["Spotify"] = "p",
 ["Firefox"] = "g",
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
local badge =      "~/.hammerspoon/vortex.png"
local tmux_badge = "~/.hammerspoon/vortex2.png"
local showing_badges = {}

function show_badge(badge)
    for i, screen in pairs(hs.screen.allScreens()) do
        local badge_size = 400
        local mode = screen:currentMode()
        local frame = screen:frame()
        local badge_rect = hs.geometry.rect(mode.w * 0.95 - badge_size / 2 + frame.x, mode.h * 0.1 - badge_size / 2 + frame.y, badge_size, badge_size)
        local badge = hs.drawing.image(badge_rect, badge)
        badge:bringToFront(true)
        badge:show()
        table.insert(showing_badges, badge)
    end
end

function clear_badge()
    for i, badge in pairs(showing_badges) do
        badge:hide()
    end
    showing_badges = {}
end

-- Show badge when in mode.
function mode:entered() show_badge(badge) end
function mode:exited()  clear_badge()     end

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
    if win ~= nil then
        local screen = win:screen()
        local newScreen = screen:previous()
        win:moveToScreen(newScreen, 0)
    end
end)
mode:bind({}, "right", function() 
    local win = hs.window.focusedWindow()
    if win ~= nil then
        local screen = win:screen()
        local newScreen = screen:next()
        win:moveToScreen(newScreen, 0)
    end
end)

function window_id_comparator(win1, win2)
    return win1:id() < win2:id()
end

-----------------------
-----------------------
-----------------------

--------------------
--- Tmux Control ---
--------------------

-- Create tmux mode
local tmux_mode = hs.hotkey.modal.new({"shift"}, "escape")
tmux_mode:bind({}, 'escape', function() tmux_mode:exit() end)

-- Which tmux session are we controlling?
tmux_host = "localhost"

-- Tmux mode switching from global mode
function tmux_mode:entered()
    show_badge(tmux_badge)
    focus_app("iTerm2")
end
function tmux_mode:exited()  clear_badge() end
mode:bind({}, "t", function()
    -- Avoid flash
    show_badge(tmux_badge)

    -- Must exit mode before next mode can be activated
    mode:exit()

    tmux_mode:enter()
end)

-- Create Environment
home = os.getenv("HOME")
tmux_path = home .. "/dev/homebrew/bin/tmux"

function all_tmux_hosts()
    hosts = {}
    hosts[1] = "localhost"

    for line in io.lines(home .. "/.ssh/config") do
        if string.sub(line, 1, 5) == "Host " and string.sub(line, 1, 6) ~= "Host *" then
            hosts[#hosts + 1] = string.sub(line, 6, #line)
        end
    end
    return hosts
end

function current_tmux_host()
    hosts = all_tmux_hosts()
    for i, host in pairs(hosts) do
        if host == tmux_host then
            return i
        end
    end
end

-- Read variables from tmux using display-message
function tmux_read_format(fmt)
    local host = tmux_host

    -- Check if this is a remote session
    local handle
    if host == "localhost" then
        handle = io.popen(tmux_path .. " display-message -p '" .. fmt .. "'")
    else
        handle = io.popen("ssh " .. host .. " /usr/bin/tmux display-message -p \"'" .. fmt .. "'\"")
        print("ssh " .. host .. " /usr/bin/tmux display-message -p \"'" .. fmt .. "'\"")
    end
    local out = handle:read("*a")
    handle:close()
    return out
end

function tmux(cmd)
    local cwd_out = tmux_read_format("#{pane_current_path}")
    cwd_out = cwd_out:gsub("%s+$", "")

    local cmd_out = tmux_read_format(cmd)
    cmd_out = cmd_out:gsub("%s+$", "")

    local command
    if tmux_host == "localhost" then
        command = "env -i TMPDIR=" .. os.getenv("TMPDIR") .. " PWD=" .. cwd_out .. " " .. tmux_path .. " " .. cmd_out
    else
        command = "ssh " .. tmux_host .. " env -i PWD=" .. cwd_out .. " /usr/bin/tmux " .. cmd_out
    end

    print(command)
    local handle = io.popen(command)
    local out = handle:read("*a")
    handle:close()
    return out
end

tmux_mode:bind({}, "s", function()
    local hosts = all_tmux_hosts()
    local host_index = current_tmux_host()

    -- Get the next tmux session
    local next_host
    if host_index == #hosts then
        next_host = hosts[1]
    else
        next_host = hosts[host_index + 1]
    end

    tmux_host = next_host
    hs.alert.show("Controlling " .. next_host .. " tmux.", 0.8)
end)

tmux_mode:bind({"shift"}, "s", function()
    local hosts = all_tmux_hosts()
    local host_index = current_tmux_host()

    -- Get the next tmux session
    local prev_host
    if host_index == 1 then
        prev_host = hosts[#hosts]
    else
        prev_host = hosts[host_index - 1]
    end

    tmux_host = prev_host
    hs.alert.show("Controlling " .. prev_host .. " tmux.", 0.8)
end)


function tmux_bind(mod, key, cmd)
    tmux_mode:bind(mod, key, function() tmux(cmd) end)
end

tmux_bind({}, "g", "split-window -v -c #{pane_current_path} -t #S:#I.")
tmux_bind({}, "v", "split-window -h -c #{pane_current_path} -t #S:#I.")
tmux_bind({}, "h", "select-pane -L -t #S:")
tmux_bind({}, "j", "select-pane -D -t #S:")
tmux_bind({}, "k", "select-pane -U -t #S:")
tmux_bind({}, "l", "select-pane -R -t #S:")
tmux_bind({}, "c", "new-window -a -c #{pane_current_path} -t #S:#I")
tmux_bind({}, "n", "next-window -t #S:")
tmux_bind({}, "p", "previous-window -t #S:")
tmux_bind({}, "x", "kill-pane -t #I.")
tmux_bind({"ctrl"}, "h", "resize-pane -L -t #S: 8")
tmux_bind({"ctrl"}, "j", "resize-pane -D -t #S: 4")
tmux_bind({"ctrl"}, "k", "resize-pane -U -t #S: 4")
tmux_bind({"ctrl"}, "l", "resize-pane -R -t #S: 8")

-- Special priority for movement keys
function tmux_move(tmux_direction, vim_keys)
    tmux("select-pane " .. tmux_direction .. " -t #S:")
end

hs.hotkey.bind({"alt"}, "h", function() tmux_move("-L", "h") end)
hs.hotkey.bind({"alt"}, "j", function() tmux_move("-D", "j") end)
hs.hotkey.bind({"alt"}, "k", function() tmux_move("-U", "k") end)
hs.hotkey.bind({"alt"}, "l", function() tmux_move("-R", "l") end)
hs.hotkey.bind({"alt", "shift"}, "l", function() tmux("next-window -t #S:") end)
hs.hotkey.bind({"alt", "shift"}, "h", function() tmux("previous-window -t #S:") end)

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

--- Audio control ---
mode:bind({}, "p", function()
    local devices = hs.audiodevice.allOutputDevices()
    local current = hs.audiodevice.current().name
    for i, device in pairs(devices) do
        if device:name() == current then
            if i == #devices then
                devices[1]:setDefaultOutputDevice()
            else
                devices[i + 1]:setDefaultOutputDevice()
            end
        end
    end
end)
