mob/player
	icon = 'icons/player.dmi'
	icon_state = "player"
	New()
		..()
		underlays += new/obj/shadow

	// Variables
	var
		// The maxes variables will be used to control the recovery of status effects
		health = 100
		max_health = 100
		power = 15
		max_power = 15
		defense = 3
		max_defense = 3
		speed = 2
		max_speed = 2
		level = 3
		exp = 0
		max_exp = 50
		attacked=FALSE

		// Sounds
		sound/level_up_sound = new/sound('sound/player/level_up.ogg')
		sound/hit_sound = new/sound('sound/player/hit.ogg')

	proc
		give_exp(amount)
			exp += amount
			Text(src, "+[amount] EXP ", "yellow")
			if(exp >= max_exp)
				level_up()

		level_up()
			Text(src, "You leveled up! ")

			exp = 0
			max_exp *= 3
			max_power += 3
			power = max_power
			health=max_health

			overlays += icon('icons/Jesse.dmi', "level_up")
			usr << level_up_sound
			spawn(15)
			overlays = null

		take_damage(damage)
			attacked=TRUE
			damage = rand(damage-3, damage+3)
			health -= damage
			s_damage(src, damage, "red")
			src << hit_sound

			if(health <= 0)
				health = max_health
				flick(new/icon('icons/player_effects.dmi', "dead"), src)
				loc=locate(4, 4, 1)
				Text(src, "YOU DIED ", "red")

			spawn(8)
			attacked=FALSE

	// Actions or commands
	verb
		Speak()
			set hidden = 1
			var/obj/emoticon/typing/EMO = new()
			overlays += EMO
			var/msg = input("", "Type Something")
			if(msg) world << "<font color = green> [client]: [msg]</font>"
			overlays -= EMO

		Attack()
			set hidden = 1
			for(var/mob/enemies/E in get_step(src, usr.dir))
				flick("attacking", src)
				E.take_damage(src)

obj
	shadow
		icon = 'icons/player.dmi'
		icon_state = "shadow"
		pixel_y = -3