var
	list/groups = new/list()
	last_position = 0

/HUD/Text
	parent_type = /obj
	screen_loc = "2, 11"
	layer = 1000
	proc
		dump(mob/M)
			animate(src, alpha=0, time=5)
			spawn(5)
				last_position -= 0.6
				M.client.screen.Remove(src)

proc/Text(mob/M,var/Text="", var/color="white")
	var/index = 0.6
	for(var/HUD/Text/Te in M.client.screen)
		Te.screen_loc = "2, 11 - [index]"
		index+=0.6
		last_position = index

	var/Blank = " "
	var/HUD/Text/T = new;M.client.screen.Add(T)

	T.maptext_width = length(Text) / length(Text)* 300
	T.maptext_height = length(Text) / length(Text)* 100
	if(last_position != 0)
		T.screen_loc = "2, 11 - [last_position]"

	while(length(Blank)-2<length(Text)+1)
		//sleep(M.TxtSpd)
		Blank = addtext(Blank,"[getCharacter(Text,length(Blank))]")
		T.maptext = "<font color = [color]><font size=0>[Blank]" // The name of the font is not its file's name.
		if(length(Blank)>=length(Text))
			break

	spawn(20)
	T.dump(M)

proc
	getCharacter(string, pos=1)
		return ascii2text(text2ascii(string, pos)) //This proc is used to retrieve the next character in text string.