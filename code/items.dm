obj/item
	icon = 'icons/Jesse.dmi'
	var
		drop_rate = 50

	apple
		icon_state = "apple"
		verb/consume()
			set src in usr

	chest
		icon_state = "slimebox"
		drop_rate = 20
		name = "Magical Chest"
		var
			is_opened=FALSE

		verb/Action()
			set hidden = 1
			set src in oview(0)
			if(!is_opened)
				flick("slimebox_opening", src)
				is_opened=TRUE
				sleep(3)
				icon_state = "slimbox_open"
				give_item(usr)

				sleep(8)
				animate(src, alpha=0, time=5)

		proc/give_item(mob/player/P)
			new/obj/item/apple(P)
	gold
		icon_state = "coin_pile"
		drop_rate = 50
		var/gold_amount = 40
		name = "Coin Pile"

		New()
			..()
			gold_amount = rand(5, 60)

		Cross(mob/player/P)
			if(istype(P,/mob/player))
				loc = P
				Text(usr, "+[gold_amount] gold ", "yellow")

		verb/consume()
			set src in usr
			del src