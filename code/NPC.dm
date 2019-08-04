mob/NPC
	icon = 'icons/npcs.dmi'

	farmer
		icon_state = "farmer"
		bound_height = 1
		bound_y = 13
		var
			list/spoked=list("")
		verb/Action()
			set src in oview(1)
			if(!spoked.Find(usr.client))
				new/obj/emoticon/angry(src)
				usr << "<font color = black><b>Farmer: Take these dirty slimes off my fields!</b></font>"

			spoked.Add(usr.client)