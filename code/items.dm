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

	Gold
		icon = 'icons/Items.dmi'
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

		// Bound values
		bound_x = 15
		bound_width = 3
		bound_y = 7
		bound_height = 3

		verb/Action()
			set hidden = 1
			set src in oview(1)
			loc = usr
			Text(usr, "+Health Potion ", "white")
			usr:Add_Item(src)


		proc/Use()
			var/Player/P = usr
			if(P.current_state[P.DEAD]) return
			P.health = P.max_health
			P.Update_Bar(list("health"))
			P << usr:healing_sound
			P.Remove_Item(src)
			del src

	MP_Potion
		icon_state = "MP_pot"
		// Bound values
		bound_x = 15
		bound_width = 3
		bound_y = 7
		bound_height = 3

		verb/Action()
			set hidden = 1
			set src in oview(1)
			loc = usr
			Text(usr, "+MP Potion ", "white")
			usr:Add_Item(src)

		proc/Use()
			var/Player/P = usr
			if(P.current_state[P.DEAD]) return
			P.mana = P.max_mana
			P.Update_Bar(list("mana"))
			P << usr:healing_sound
			P.Remove_Item(src)
			del src

	Ability
		icon = 'icons/williams.dmi'
		layer = MOB_LAYER+1
		Bow
			icon_state = "ability_bow"
			verb/Action()
				set hidden = 1
				set src in oview(1)
				var/Player/P = usr
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
			verb/Action()
				set hidden = 1
				set src in oview(1)
				var/Player/P = usr
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
			verb/Action()
				set hidden = 1
				set src in oview(1)
				var/Player/P = usr
				if(istype(P,/Player))
					if(P.INV) return
					flick("ability_get",src)
					P.INV = TRUE
					Text(P, "+Invisibility (SPACE) ", rgb(100, 255, 0))
					P << P.ability_sound
					spawn(8)
					del src