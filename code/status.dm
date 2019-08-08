obj/status
	icon = 'icons/Status.dmi'
	layer = MOB_LAYER+1
	New(mob/player/M)
		M.overlays += src
		M.poison_effect = src

	poison
		icon_state = "poison2"
		pixel_x = 1
		pixel_y = -10

	burning
		icon_state = "burning2"
		pixel_x = -2
		pixel_y = -5