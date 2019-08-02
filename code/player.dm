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
		max_exp = 10
		attacked=FALSE

	proc
		give_exp(amount)
			exp += amount
			Text(src, "+[amount] EXP ", "yellow")
			if(exp >= max_exp)
				level_up()

		level_up()
			Text(src, "You leveled up! ")

			exp = 0
			max_exp *= 2
			max_power += 10
			power = max_power

			overlays += icon('icons/Jesse.dmi', "level_up")
			spawn(15)
			overlays = null

		take_damage(damage)
			attacked=TRUE
			damage = rand(damage-3, damage+3)
			health -= damage

			if(health <= 0)
				health = max_health
				loc=locate(4, 6, 1)
				Text(src, "YOU DIED ", "red")

			spawn(8)
			attacked=FALSE

	// Actions or commands
	verb
		Speak()
			set hidden = 1
			var/msg = input("", "Type Something")
			if(msg) world << "<font color = green> [client]: [msg]</font>"

		Attack()
			set hidden = 1
			for(var/mob/enemies/E in get_step(src, usr.dir))
				E.take_damage(src)