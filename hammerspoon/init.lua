require "os"

-- Main keybinding
unmodal = {"shift", "alt"}
modal = {"alt"}

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
        app:activate()
    end
end

-- Bind windows to hotkeys
for name, key in pairs(apps) do
    hs.hotkey.bind(unmodal, key, focus_app)
end


-- Set up modal bindings.
local mode = hs.hotkey.modal.new(modal, "escape")
local tmux_mode = hs.hotkey.modal.new(nil, nil)
mode:bind({}, 'escape', function() mode:exit() end)
mode:bind(modal, 'escape', function() mode:exit() end)
tmux_mode:bind({}, 'escape', function() tmux_mode:exit() end)
tmux_mode:bind(modal, 'escape', function() tmux_mode:exit() end)

-- Set up badge for modal keybinding.
local screen = hs.screen.allScreens()[1]
local badge_size = 800
local badge_rect = hs.geometry.rect(screen:currentMode().w / 2 - badge_size / 2, screen:currentMode().h / 2 - badge_size / 2, badge_size, badge_size)
local badge = hs.drawing.image(badge_rect, "~/.hammerspoon/vortex.png")
local tmux_badge = hs.drawing.image(badge_rect, "~/.hammerspoon/vortex2.png")
badge:bringToFront(true)
tmux_badge:bringToFront(true)

-- Show badge when in mode.
function mode:entered() badge:show() end
function mode:exited()  badge:hide() end
function tmux_mode:entered() tmux_badge:show() end
function tmux_mode:exited()  tmux_badge:hide() end

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

direct("a", function(w, h) return {x = 0, y = 0, w = w/2, h = h} end)
direct("d", function(w, h) return {x = w/2, y = 0, w = w/2, h = h} end)
direct("w", function(w, h) return {x = 0, y = 0, w = w, h = h/2} end)
direct("s", function(w, h) return {x = 0, y = h/2, w = w, h = h/2} end)

direct("q", function(w, h) return {x = 0, y = 0, w = w/2, h = h/2} end)
direct("e", function(w, h) return {x = w/2, y = 0, w = w/2, h = h/2} end)
direct("z", function(w, h) return {x = 0, y = h/2, w = w/2, h = h/2} end)
direct("c", function(w, h) return {x = w/2, y = h/2, w = w/2, h = h/2} end)

direct("x", function(w, h) return {x = 0, y = 0, w = w, h = h} end)
mode:bind({"shift"}, "x", function() 
    local win = hs.window.focusedWindow()
    win:toggleFullScreen()
end)

-- Tmux control
home = os.getenv("HOME")
temp = home .. "/.tmp-tmux-hammerspoon"
tmux_path = home .. "/dev/homebrew/bin/tmux"

function tmux_read_format(fmt)
    local handle = io.popen(tmux_path .. " display-message -p '" .. fmt .. "'")
    local out = handle:read("*a")
    handle:close()
    return out
end

function tmux(fun, target)
    -- Get target name, whatever it is
    local target_out = tmux_read_format(target)
    local cwd_out = tmux_read_format("#{pane_current_path}")
    cwd_out = cwd_out:gsub("%s+", "")

    local command = "env -i TMPDIR=" .. os.getenv("TMPDIR") .. " PWD=" .. cwd_out .. " " .. tmux_path .. " " .. fun() .. " -t " .. target_out
    os.execute(command)
end

mode:bind({}, "t", function()
    mode:exit()
    tmux_mode:enter()
    focus_app("iTerm")
end)

function tmux_bind(key, cmd, target)
    tmux_mode:bind({}, key, function() tmux(function() return cmd end, target) end)
end
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
tmux_bind("w", "select-pane -U", "\\$#S")
tmux_bind("a", "select-pane -L", "\\$#S")
tmux_bind("s", "select-pane -D", "\\$#S")
tmux_bind("d", "select-pane -R", "\\$#S")
tmux_bind_fun("c", function()
    local dir = tmux_read_format("#{pane_current_path}")
    return "new-window -c " .. dir
end, "#I")
tmux_bind("n", "next-window", "\\$#S")
tmux_bind("p", "previous-window", "\\$#S")
