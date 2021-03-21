--[[

	\d   the date in “Weekday Month Date” format (e.g., “Tue May 26”)
	\h   The hostname.
	\t   the current time in 24-hour HH:MM:SS format
	\T   the current time in 12-hour HH:MM:SS format
	\@   the current time in 12-hour am/pm format
	\A   the current time in 24-hour HH:MM format
	\w   The current working directory.

	\n   A newline.

	Colors
		$ Background
		& Forground

		0 white
		1 orange
		2 magenta
		3 lightBlue
		4 yellow
		5 lime
		6 pink
		7 gray
		8 lightGray
		9 cyan
		a purple
		b blue
		c brown
		d green
		e red
		f black
]]

_G.PS1="&b(&e\h&b)-[&0\w&b]\n&e# "
