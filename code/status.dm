obj/status
	icon = 'icons/Status.dmi'
	layer = MOB_LAYER+1
	var
		delay = 80
	New(mob/player/M)
		M.overlays += src
		M.poison_effect = src

		spawn(delay)
			M.overlays -= src
			M.is_poisoned = FALSE

	poison
		icon_state = "poison2"
		pixel_x = 1
		pixel_y = -10
		New(mob/player/M)
			..(M)
			var/default_icon = M.icon
			M.icon += rgb(100, 0, 125)
			spawn(delay)
			M.icon = default_icon

	burning
		icon_state = "burning2"
		pixel_x = -2
		pixel_y = -5
		New(mob/player/M)
			..(M)
			var/default_icon = M.icon
			M.icon += rgb(200, 0, 0)
			spawn(delay)
			M.icon = default_icon