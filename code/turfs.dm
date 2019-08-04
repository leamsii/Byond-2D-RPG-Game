turf
	icon = 'icons/turfs.dmi'
	grass
		icon_state = "grass_1"
	rock
		icon_state = "rock"
		density=1
	flowers
		icon_state = "flowers"

	b
		density=1
obj/sign
	icon = 'icons/turfs.dmi'
	icon_state = "sign"
	density = 1
	bound_y = 10
	bound_height = 10
	bound_x = 10
	bound_width = 10
obj/
	icon = 'icons/turfs.dmi'
	bottom_right
		icon_state = "tree_bottom_right"
		density = 1
		pixel_x = 10
		bound_x = 10
		bound_width = 10
		bound_y = 10
		bound_height = 15

	mid_left
		icon_state = "tree_mid_left"
		pixel_x = -11
		pixel_y = 24
		layer=TURF_LAYER+10

	mid_right
		icon_state = "tree_mid_right"
		pixel_x = 11
		pixel_y = 24
		layer=TURF_LAYER+10

	top_right
		icon_state = "tree_top_right"
		pixel_x = 10
		pixel_y = 48
		layer=TURF_LAYER+10
	top_left
		icon_state = "tree_top_left"
		pixel_x = -10
		pixel_y = 48
		layer=TURF_LAYER+10

obj/tree
	icon = 'icons/turfs.dmi'
	icon_state = "tree_bottom_left"
	density = 1
	pixel_x = -10
	bound_x = 0
	bound_width = 10
	bound_y = 10
	bound_height = 15
	New()
		..()
		//new/obj/bottom_left(loc)
		new/obj/bottom_right(loc)
		new/obj/mid_left(loc)
		new/obj/mid_right(loc)
		new/obj/top_left(loc)
		new/obj/top_right(loc)