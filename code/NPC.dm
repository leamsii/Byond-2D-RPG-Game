NPC
	icon = 'icons/npcs.dmi'
	parent_type = /mob

	Grandpa
		icon_state = "grandpa"

		// Define its collison rect
		bound_height = 24
		bound_y = 4
		bound_width = 34
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
				usr << "<font color = black><b>Old Man: Don't take this here portal, you die.</b></font>"

				spoked.Add(usr.client)