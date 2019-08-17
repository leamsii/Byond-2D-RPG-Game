var
	list/groups = new/list()
	last_position = 0


/HUD/Text
	parent_type = /obj
	screen_loc = "2, 2"
	layer = 1000
	proc
		dump(mob/M)
			last_position -= 0.65
			animate(src, alpha=0, time=5)
			spawn(5)
				M.client.screen.Remove(src)

proc/Text(mob/M,var/Text="", var/color="white")
	var/index = 0
	for(var/HUD/Text/Te in M.client.screen)
		Te.screen_loc = "2, 2 + [index]"
		index+=0.65
		last_position = index

	var/Blank = " "
	var/HUD/Text/T = new;M.client.screen.Add(T)

	T.maptext_width = length(Text) / length(Text)* 300
	T.maptext_height = length(Text) / length(Text)* 100
	T.screen_loc = "2, 2 + [last_position]"

	index = -6
	while(length(Blank)-2<length(Text)+1)
		//sleep(M.TxtSpd)
		Blank = addtext(Blank,"[getCharacter(Text,length(Blank))]")
		T.maptext = "<font color = [color] size=1>[Blank]" // The name of the font is not its file's name.

		// Black bar underlay
		var/HUD/black_bar/BAR = new()
		BAR.pixel_x = index
		index+=7
		T.underlays += BAR

		if(length(Blank)>=length(Text))
			break

	spawn(20)
	T.dump(M)

proc
	getCharacter(string, pos=1)
		return ascii2text(text2ascii(string, pos)) //This proc is used to retrieve the next character in text string.


HUD
	black_bar
		icon = 'icons/Jesse.dmi'
		icon_state = "black_bar"
		pixel_y = -10