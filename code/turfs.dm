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
		icon_state = "b"
		density=1
		New()
			..()
			icon_state = ""
	fence
		icon = 'icons/large_turfs.dmi'
		icon_state = "fence_mid"

	tall_grass
		density = 1
		layer=MOB_LAYER+1
		icon = 'icons/williams.dmi'
		icon_state = "tall_grass"

	tree
		layer = MOB_LAYER+1
		icon = 'icons/orange_tree.dmi'
		icon_state = "tree"

obj/sign
	icon = 'icons/turfs.dmi'
	icon_state = "sign"
	density = 1
	bound_y = 10
	bound_height = 10
	bound_x = 10
	bound_width = 10
obj/m_tree
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
		pixel_x = 11
		pixel_y = 48
		layer=TURF_LAYER+10
	top_left
		icon_state = "tree_top_left"
		pixel_x = -11
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
		new/obj/m_tree/bottom_right(loc)
		new/obj/m_tree/mid_left(loc)
		new/obj/m_tree/mid_right(loc)
		new/obj/m_tree/top_left(loc)
		new/obj/m_tree/top_right(loc)


obj/m_house
	icon = 'icons/house.dmi'
	icon_state = "bottom_left"
	density = 1
	pixel_x = -10
	bound_x = 0
	bound_width = 10
	bound_y = 10
	bound_height = 15
	New()
		..()
		//new/obj/bottom_left(loc)
		new/obj/house/bottom_right(loc)
		new/obj/house/top_left(loc)
		new/obj/house/top_right(loc)

obj/
	icon = 'icons/house.dmi'
	house
		bottom_right
			icon_state = "bottom_right"
			density = 1
			pixel_x = 10
			bound_x = 10
			bound_width = 10
			bound_y = 10
			bound_height = 15

		top_right
			icon_state = "top_right"
			pixel_x = 11
			pixel_y = 20
			layer=TURF_LAYER+10
		top_left
			icon_state = "top_left"
			pixel_x = -11
			pixel_y = 20
			layer=TURF_LAYER+10