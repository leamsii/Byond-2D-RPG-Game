obj/item
	icon = 'icons/Jesse.dmi'
	var
		drop_rate = 50
	gold
		drop_rate = 50
		var/gold_amount = 40
		name = "Coin Pile"
		icon_state = "coin_pile"
		var/sound/gold_sound = new/sound('sound/player/gold_pick.ogg')

		New()
			..()
			gold_amount = rand(5, 60)

		Crossed(mob/player/P)
			if(istype(P,/mob/player))
				loc = P
				P << gold_sound
				Text(usr, "+[gold_amount] gold ", "yellow")