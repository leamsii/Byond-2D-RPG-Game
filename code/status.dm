obj/status
	icon = 'icons/Status.dmi'
	layer = MOB_LAYER+1
	var
		_color = null
		delay = 100

	proc
		remove_effect(mob/player/P)
			P.poison_effect = null
			P.overlays -= src
			P.is_poisoned = FALSE

	New(mob/player/M)
		M.overlays += src
		M.poison_effect = src
		//M.icon += _color

		spawn(delay)
			if(M.poison_effect == src)
				remove_effect(M)

	poison
		icon_state = "poison2"
		pixel_x = 1
		pixel_y = -10
		_color = rgb(100, 0, 125)

	burning
		icon_state = "burning2"
		pixel_x = -2
		pixel_y = -5
		_color = rgb(200, 0, 0)