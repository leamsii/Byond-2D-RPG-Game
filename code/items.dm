obj/item
	icon = 'icons/Jesse.dmi'
	var
		drop_rate = 50

	chest
		icon_state = "slimebox"
		drop_rate = 0
	gold
		icon_state = "coin_pile"
		drop_rate = 50
		var/gold_amount = 40

		New()
			..()
			gold_amount = rand(5, 60)

		Cross(mob/player/P)
			if(istype(P,/mob/player))
				P << "You picked up [gold_amount] gold coins!"
				loc = P