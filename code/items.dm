obj/item
	icon = 'icons/Jesse.dmi'
	var
		drop_rate = 50
	gold
		drop_rate = 40
		layer=MOB_LAYER-1
		var/gold_amount = 40
		name = "Coin Pile"
		icon_state = "coin_pile"
		var/sound/gold_sound = new/sound('sound/player/gold_pick.ogg', volume=30)

		New(mob/enemies/owner)
			..()
			gold_amount = round(owner.exp / 3)

		Cross(mob/player/P)
			if(istype(P,/mob/player))
				loc = P
				P << gold_sound
				Text(usr, "+[gold_amount] gold ", "yellow")

	HP_Potion
		icon_state = "HP_pot"
		drop_rate=20
		Cross(mob/player/P)
			if(istype(P,/mob/player))
				loc = P
				P.health = P.max_health
				P.update_health_bar()
				Text(usr, "+ Health Potion ", "white")