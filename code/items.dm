obj/item
	icon = 'icons/Jesse.dmi'
	var
		drop_rate = 100
		gold_amount = 0

	New(mob/enemies/owner, dr)
		..()
		drop_rate = dr

		if(istype(src,/obj/item/gold))
			gold_amount = round(owner.exp / 3)

			if(gold_amount >= 20)
				icon_state = "sack"
			else if(gold_amount < 20 && gold_amount >= 10)
				icon_state = "med"
			else
				icon_state = "small"

	gold
		icon = 'icons/items.dmi'
		layer=MOB_LAYER-1
		name = "Coin Pile"
		icon_state = "sack"
		var/sound/gold_sound = new/sound('sound/player/gold_pick.ogg', volume=30)

		// Bound values
		bound_x = 10
		bound_width = 10
		bound_y = 10
		bound_height = 2

		Cross(mob/player/P)
			if(istype(P,/mob/player))
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

		Cross(mob/player/P)
			if(istype(P,/mob/player))
				loc = P
				P.health = P.max_health
				P.update_bars()
				Text(usr, "+Health Potion ", "white")
	MP_Potion
		icon_state = "MP_pot"
		layer=MOB_LAYER+1

		// Bound values
		bound_x = 15
		bound_width = 3
		bound_y = 7
		bound_height = 3

		Cross(mob/player/P)
			if(istype(P,/mob/player))
				loc = P
				P.mana = P.max_mana
				P.update_bars()
				Text(usr, "+MP Potion ", "white")
	Chest
		icon_state = "chest"
		layer=MOB_LAYER+1

		// Bound values
		bound_x = 15
		bound_width = 3
		bound_y = 7
		bound_height = 3
