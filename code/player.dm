mob/player
	icon = 'icons/temp_player.dmi'
	icon_state = "player"

	// Variables
	var
		// The maxes variables will be used to control the recovery of status effects
		health = 100
		max_health = 100
		power = 20
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
				level_up()
			src << "You gained [amount] exp!"

		level_up()
			src << "You leveled up!"

			exp = 0
			max_exp *= 2
			max_power += 10
			power = max_power

		take_damage(damage)
			damage = rand(damage-3, damage+3)
			health -= damage
			src << "You've been hit [damage] damage!"

			if(health <= 0)
				health = max_health
				loc=locate(4, 6, 1)
				src << "YOU DIED!"

	// Actions or commands
	verb
		Speak()
			var/msg = input("", "Type Something")
			if(msg) world << "<font color = green> [client]: [msg]</font>"

		Attack()
			for(var/mob/enemies/E in get_step(src, usr.dir))
				E.take_damage(src)

		Test_Effects()
			overlays += new/icon('icons/Status.dmi', "poison")