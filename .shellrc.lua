--[[
	\h   The hostname.
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
