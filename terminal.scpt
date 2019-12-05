on run argv
	tell application "Terminal"
		get background color of current settings of first window whose tty is item 1 of argv
	end tell
	if 2 * ((integer 1 of result) + (integer 2 of result) + (integer 3 of result)) < 65535 * 3 then
		"dark"
	else
		"light"
	end if
end run
