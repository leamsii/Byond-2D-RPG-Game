NPC
	icon = 'icons/npcs.dmi'
	parent_type = /mob

	Farmer
		icon_state = "farmer"

		// Define its collison rect
		bound_height = 32
		bound_y = 1
		bound_width = 32
		bound_x = 1

		// Properties
		var
			list/spoked=list("")

		// Commands
		verb/Action()
			set hidden = 1
			set src in oview(1)
			if(!spoked.Find(usr.client))
				new/Emoticon/Angry(src, -20, 17)
				usr << "<font color = black><b>Farmer: Bitch nigga Justin you ain't gonna kill me!</b></font>"

				spoked.Add(usr.client)