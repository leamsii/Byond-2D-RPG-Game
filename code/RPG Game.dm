/*
	These are simple defaults for your project.
 */

world
	fps = 40		// 40 frames per second
	icon_size = 24	// 32x32 icon size by default
	view = "43x28"


// Make objects move 8 pixels per tick when walking

mob
	step_size = 3

obj
	step_size = 4

client.New()
	mob = new/mob/player
	perspective = EDGE_PERSPECTIVE
	view = "17x11"

	// Add the macros
	for(var/i=0;i < 4; i++)
		var/obj/HUD/macro/O = new()
		var/x = 1.4 + (i * 1.3)
		O.screen_loc = "[x], 1.3"
		screen += O
		O.name = "[i + 1]"

mob/Login()
	Move(locate(6, 8, 1))