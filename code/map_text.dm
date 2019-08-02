mob/var/TxtSpd = 0.5

var/list/font_resources = list('fonts/pkmnrs.ttf') // To use A font you first need to specify the file somewhere. Let's do it now! :)
/HUD/Text
	parent_type = /obj
	screen_loc = "2, 11"
	layer = 1000
	var
		del_delay = 50

var/list/groups = new/list()

proc/Text(mob/M,var/Text="", var/color="white")

	var/index = 1
	for(var/HUD/Text/Te in groups)
		Te.screen_loc = "2, 11 - [index]"
		index+=1

	var/Blank = " "
	var/HUD/Text/T = new;M.client.screen.Add(T)

	groups += T

	T.maptext_width = length(Text) / length(Text)*300
	T.maptext_height = length(Text) / length(Text)*100
	while(length(Blank)-2<length(Text)+1)
		//sleep(M.TxtSpd)
		Blank = addtext(Blank,"[getCharacter(Text,length(Blank))]")
		T.maptext = "<font color = [color] face=\"Power Red and Blue\"><font size=2>[Blank]" // The name of the font is not its file's name.
		if(length(Blank)>=length(Text))
			break

	for(var/HUD/Text/Te in groups)
		//animate(Te, alpha=0, time=Te.del_delay)
		spawn(Te.del_delay)
		del Te


proc
	getCharacter(string, pos=1)
		return ascii2text(text2ascii(string, pos)) //This proc is used to retrieve the next character in text string.