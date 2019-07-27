/*
	These are simple defaults for your project.
 */

world
	fps = 40		// 40 frames per second
	icon_size = 24	// 32x32 icon size by default
	view = 6		// show up to 6 tiles outward from center (13x13 view)world



// Make objects move 8 pixels per tick when walking

mob
	step_size = 3

obj
	step_size = 4

client.New()
	src.mob = new/mob/player
	world << "[src] has joined the world!"

mob/Login()
	Move(locate(12, 12, 1))