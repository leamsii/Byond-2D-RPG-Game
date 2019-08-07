/*
	These are simple defaults for your project.
 */

world
	fps = 40		// 40 frames per second
	icon_size = 24	// 32x32 icon size by default
	view = "43x28"


// Make objects move 8 pixels per tick when walking

mob
	step_size = 2

obj
	step_size = 4

client.New()
	src << new/sound('sound/player/elina.ogg')
	mob = new/mob/player
	perspective = EDGE_PERSPECTIVE
	screen += new/obj/HUD/health_bar()
	screen += new/obj/HUD/exp_bar()
	view = "17x11"
	world << "[src] has joined the game!"


mob/Login()
	Move(locate(4, 4, 1))