turf
	icon = 'icons/turfs.dmi'
	grass
		icon_state = "grass_1"
	rock
		icon_state = "rock"
		density=1
	b
		density=1

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
		layer=MOB_LAYER+1

	mid_right
		icon_state = "tree_mid_right"
		pixel_x = 11
		pixel_y = 24
		layer=MOB_LAYER+1

	top_right
		icon_state = "tree_top_right"
		pixel_x = 10
		pixel_y = 48
		layer=MOB_LAYER+1
	top_left
		icon_state = "tree_top_left"
		pixel_x = -10
		pixel_y = 48
		layer=MOB_LAYER+1

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