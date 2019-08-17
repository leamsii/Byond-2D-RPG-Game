Item
	icon = 'icons/Jesse.dmi'
	parent_type = /obj
	var
		drop_rate = 100
		gold_amount = 0

	New(Enemies/owner, drop_rate)
		..()
		src.drop_rate = drop_rate

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
				P.health = P.max_health
				P.Update_Bar(list("health"))
				Text(usr, "+Health Potion ", "white")
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