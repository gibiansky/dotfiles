activate application "Firefox"
tell application "System Events" 
    keystroke "y"
    key down command
    keystroke "n"
    key up command
    delay 0.5
end tell
