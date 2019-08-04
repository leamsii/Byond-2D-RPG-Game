mob/NPC
	icon = 'icons/npcs.dmi'

	farmer
		icon_state = "farmer"
		bound_height = 1
		bound_y = 13
		var
			list/spoked=list("")
		verb/Action()
			set hidden = 1
			set src in oview(1)
			if(!spoked.Find(usr.client))
				new/obj/emoticon/angry(src, -20, 17)
				usr << "<font color = black><b>Farmer: There's a huge flower monster on my field!</b></font>"

			spoked.Add(usr.client)