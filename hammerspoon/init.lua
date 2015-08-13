-- Non-standard homebrew install.
--require "os"
--require "string"
--local homebrew = string.format("%s/dev/homebrew", os.getenv("HOME"))
--package.path  = package.path  .. string.format(";%s/share/lua/5.2/?.lua", homebrew)
--package.cpath = package.cpath .. string.format(";%s/lib/lua/5.2/?.so", homebrew)
--
----------------------------------------------------------------------------------
------ mjolnir extensions
------------------------------------------------------------------------------------
--local application = require "mjolnir.application"
--local hotkey = require "mjolnir.hotkey"
--local window = require "mjolnir.window"
--local fnutils = require "mjolnir.fnutils"
--local appfinder = require "mjolnir.cmsj.appfinder"
--local alert = require "mjolnir.alert"

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
}

-- Bind windows to hotkeys
for name, key in pairs(apps) do
    hs.hotkey.bind(unmodal, key, function()
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
    end)
end


-- Set up modal bindings.
mode = hs.hotkey.modal.new(modal, "escape")
mode:bind({}, 'escape', function() mode:exit() end)
mode:bind(modal, 'escape', function() mode:exit() end)

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
mode:bind({}, "h", function()
    hs.alert.show("what")
end)

