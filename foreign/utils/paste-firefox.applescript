activate application "Firefox"
tell application "System Events" 
    delay 0.3
    key down command
    keystroke "l"
    delay 0.1
    keystroke "v"
    delay 0.1
    key up command
    key code 36
    delay 0.1
end tell
