/*
	These are simple defaults for your project.
 */

world
	fps = 50		// 50 frames per second
	icon_size = 24	// 32x32 icon size by default
	view = "43x28"


// Make objects move 8 pixels per tick when walking
mob
	step_size = 2
obj
	step_size = 3

client.New()
	mob = new/Player()
	view = "17x11"
	perspective = EDGE_PERSPECTIVE
	src << sound('sound/player/forest_track.wav',volume=50, repeat=1)

	for(var/Player/P in world)
		P << "[src] has joined the game!"

	mob.loc=locate(3,6,1)


Player
	Login()
		..()
		health_bar = new/HUD/health_bar(client)
		new/HUD/Key_Slots/Slot1(client)
		mana_bar = new/HUD/mana_bar()
		exp_bar = new/HUD/exp_bar()
		client.screen += health_bar
		client.screen += mana_bar
		client.screen += exp_bar

		Create_Text(src, "100/100", 3, 10)
