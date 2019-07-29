mob/player
	icon = 'icons/temp_player.dmi'
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
		level = 3
		exp = 0
		max_exp = 100
	proc
		give_exp(amount)
			exp += amount
			if(exp >= max_exp)
				exp = 0
				max_exp *= 2
				src << "You leveled up!"
				max_power += 100
				power = max_power

			src << "You gained [amount] exp!"

		take_damage(damage)
			var/sound/S = new('sound/slime/hit.wav')
			src << S
			damage = rand(damage-3, damage+3)
			src << "You've been hit [damage] damage!"

	// Actions or commands
	verb
		Speak()
			var/msg = input("", "Type Something")
			if(msg) world << "<font color = green> [client]: [msg]</font>"

		Attack()
			var/sound/S = new('sound/slime/hit.wav')
			for(var/mob/enemies/E in get_step(src, usr.dir))
				src << S
				E.take_damage(src)