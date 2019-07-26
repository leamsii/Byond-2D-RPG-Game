mob/player
	icon = 'temp_player.dmi'
	icon_state = "player"

	// Variables
	var
		// The maxes variables will be used to control the recovery of status effects
		health = 100
		max_health = 100
		power = 10
		max_power = 10
		defense = 3
		max_defense = 3
		speed = 2
		max_speed = 2

	// Actions or commands
	verb
		Speak()
			var/msg = input("", "Type Something")
			if(msg) world << "<font color = red> [client]: [msg]</font>"
		Attack()
			for(var/mob/enemies/E in oview(1))
				E.take_damage(src)