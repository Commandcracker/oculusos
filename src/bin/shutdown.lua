if term.isColour() then
	term.setTextColour(colours.orange)
end
print("Goodbye")
term.setTextColour(colours.white)

sleep(1)
os.shutdown()
