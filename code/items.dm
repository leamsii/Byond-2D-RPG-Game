obj/item
	icon = 'icons/items.dmi'
	density=1
	var
		drop_rate = 50

	chest
		icon_state = "chest"
		drop_rate = 0
	gold
		icon_state = "gold"
		drop_rate = 50
		var/gold_amount = 40

		New()
			..()
			gold_amount = rand(5, 60)

		Cross(mob/player/P)
			if(istype(P,/mob/player))
				P << "You picked up [gold_amount] gold coins!"
				loc = P