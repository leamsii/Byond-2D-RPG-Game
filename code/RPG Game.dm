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
	src.mob = new/mob/player
	world << "[src] has joined the world!"
	perspective = EDGE_PERSPECTIVE
	view = "17x11"

mob/Login()
	Move(locate(6, 8, 1))