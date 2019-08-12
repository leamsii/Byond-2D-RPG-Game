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
	mob = new/Player
	view = "17x11"
	perspective = EDGE_PERSPECTIVE
	src << sound('sound/player/elina.ogg')
	world << "[src] has joined the game!"


Player/Login()
	..()
	health_bar = new/HUD/health_bar()
	mana_bar = new/HUD/mana_bar()
	exp_bar = new/HUD/exp_bar()
	client.screen += health_bar
	client.screen += mana_bar
	client.screen += exp_bar

	loc=locate(12, 44, 1)
	dir=SOUTH