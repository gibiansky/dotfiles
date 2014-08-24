global frontApp, frontAppName
tell application "System Events"
	set frontApp to first application process whose frontmost is true
	set frontAppName to name of frontApp
end tell

if frontAppname is in {"Pandora", "Pages"}
    tell application "System Events" to tell application process frontAppName
        set winloc to get position of the front window
    end tell
else
    tell application frontAppName
        set winloc to bounds of the front window
    end tell
end if

set x to (item 1 of winloc) + 80
set y to (item 2 of winloc) + 10

if frontAppName is "Mathematica"
    set y to y - 20
end if

do shell script "/usr/local/bin/MouseTools -x " & x & " -y " & y & " -leftClickNoRelease"
delay 0.8
do shell script "/usr/local/bin/MouseTools -releaseMouse"
