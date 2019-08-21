var
	const
		// IDS don't refrence a list
		MP_POTION_ID = 0
		HP_POTION_ID = 1
		GOLD_ID = 2
		INV_AB = 3
		TEL_AB = 4
		BOW_AB = 5

Item
	icon = 'icons/Jesse.dmi'
	parent_type = /obj
	var
		gold_amount = 0
		ACTIVE = FALSE

	New(Enemies/owner)
		..()

		if(istype(src,/Item/Gold))
			gold_amount = round(owner.exp / rand(2,  3)) // Control the amount of gold dropped from enemies

			if(gold_amount >= 20 && gold_amount < 50)
				icon_state = "large"
			else if(gold_amount > 50)
				icon_state = "sack"
			else if(gold_amount < 20 && gold_amount >= 10)
				icon_state = "med"
			else
				icon_state = "small"

	proc/Use()

	Gold
		icon = 'icons/Items.dmi'
		layer=MOB_LAYER-1
		icon_state = "sack"
		var
			sound/gold_sound = new/sound('sound/player/gold_pick.ogg', volume=30)

		// Bound values
		bound_x = 10
		bound_width = 10
		bound_y = 10
		bound_height = 2

		Cross(Player/P)
			if(istype(P,/Player))
				loc = P
				P << gold_sound
				Text(usr, "+[gold_amount] gold ", "yellow")

	HP_Potion
		icon_state = "HP_pot"
		layer=MOB_LAYER+1

		// Bound values
		bound_x = 15
		bound_width = 3
		bound_y = 7
		bound_height = 3

		Cross(Player/P)
			if(istype(P,/Player))
				loc = P
				Text(usr, "+Health Potion ", "white")
				P.Add_Item(src)


		Use()
			usr:health = usr:max_health
			usr:Update_Bar(list("health"))
			usr << usr:healing_sound
			usr:Remove_Item(src)
			del src

	MP_Potion
		icon_state = "MP_pot"
		layer=MOB_LAYER+1

		// Bound values
		bound_x = 15
		bound_width = 3
		bound_y = 7
		bound_height = 3

		Cross(Player/P)
			if(istype(P,/Player))
				loc = P
				P.mana = P.max_mana
				P.Update_Bar(list("mana"))
				Text(usr, "+MP Potion ", "white")

				P << P.healing_sound

	Ability
		icon = 'icons/williams.dmi'
		layer = MOB_LAYER+1
		Bow
			icon_state = "ability_bow"
			Cross(Player/P)
				if(istype(P,/Player))
					if(P.ARCHER) return
					flick("ability_get",src)
					P.ARCHER = TRUE
					Text(P, "+BOW (S) ", rgb(100, 255, 0))
					P << P.ability_sound
					spawn(10)
					del src

		Teleport
			icon_state = "ability_teleport"
			Cross(Player/P)
				if(istype(P,/Player))
					if(P.TELB) return
					flick("ability_get",src)
					P.TELB = TRUE
					Text(P, "+TELEPORT (D) ", rgb(100, 255, 0))
					P << P.ability_sound
					spawn(8)
					del src
		Invisible
			icon_state = "ability_inv"
			Cross(Player/P)
				if(istype(P,/Player))
					if(P.INV) return
					flick("ability_get",src)
					P.INV = TRUE
					Text(P, "+Invisibility (SPACE) ", rgb(100, 255, 0))
					P << P.ability_sound
					spawn(8)
					del src