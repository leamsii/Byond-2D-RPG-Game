obj/item
	icon = 'icons/Jesse.dmi'
	var
		drop_rate = 50
	gold
		icon = 'icons/items.dmi'
		drop_rate = 40
		layer=MOB_LAYER-1
		var/gold_amount = 40
		name = "Coin Pile"
		icon_state = "sack"
		var/sound/gold_sound = new/sound('sound/player/gold_pick.ogg', volume=30)

		// Bound values
		bound_x = 10
		bound_width = 10
		bound_y = 10
		bound_height = 2

		New(mob/enemies/owner)
			..()
			gold_amount = round(owner.exp / 3)
			if(gold_amount >= 20)
				icon_state = "sack"
			else if(gold_amount < 20 && gold_amount >= 10)
				icon_state = "med"
			else
				icon_state = "small"

		Cross(mob/player/P)
			if(istype(P,/mob/player))
				loc = P
				P << gold_sound
				Text(usr, "+[gold_amount] gold ", "yellow")

	HP_Potion
		icon_state = "HP_pot"
		drop_rate=20
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
				P.update_health_bar()
				Text(usr, "+ Health Potion ", "white")