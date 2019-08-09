mob/player
	icon = 'icons/player.dmi'
	icon_state = "player"
	Move()
		if(!is_dead)
			return ..()
	New()
		..()
		underlays += new/obj/shadow
		update()

	// Variables
	var
		// The maxes variables will be used to control the recovery of status effects
		health = 50
		max_health = 50
		power = 13
		max_power = 8
		defense = 3
		max_defense = 3
		speed = 2
		max_speed = 2
		level = 1
		exp = 0
		max_exp = 100
		attacked=FALSE
		attacking=FALSE
		mana = 50
		max_mana = 50

		// Sounds
		sound/level_up_sound = new/sound('sound/player/level_up.ogg', volume=30)
		sound/hit_sound = new/sound('sound/player/hit.ogg', volume=30)
		sound/bow_shot = new/sound('sound/player/bow_shot.wav', volume=20)

		// Effects
		is_poisoned = FALSE
		poison_effect = null
		is_dead = FALSE
		tele_cooldown = 1
		teleported = FALSE

	proc
		effect(effect)
			if(effect == "burn")
				new/obj/status/burning(src)
			if(effect == "poison")
				new/obj/status/poison(src)

			is_poisoned = TRUE

		get_bar_state(val, max_val, num)
			var/max = max(max_val,0.000001) // The larger value, or denominator
			var/min = min(max(val),max) // The smaller value, or numerator
			var/state = "[round((num-1)*min/max,1)+1]" // Get the percentage and scale it by number of states

			return state

		update_bars()
			if(health < 0) health = 0
			if(mana < 0) mana = 0

			//Health
			for(var/obj/HUD/health_bar/O in client.screen)
				O.icon_state = get_bar_state(health, max_health, 10)

			//EXP
			for(var/obj/HUD/exp_bar/O in client.screen)
				O.icon_state = get_bar_state(exp, max_exp, 6)

			//Mana
			for(var/obj/HUD/mana_bar/O in client.screen)
				O.icon_state = get_bar_state(mana, max_mana, 10)

		give_exp(amount)
			exp += amount
			Text(src, "+[amount] EXP ", "yellow")
			if(exp >= max_exp)
				level_up()

			update_bars()

		level_up()
			Text(src, "You leveled up! ")

			exp = 0
			max_exp *= 2
			max_power += 3
			power = max_power
			health += max_health / 2
			if(health >= max_health)
				health = max_health
			max_health += 20

			update_bars()

			overlays += icon('icons/Jesse.dmi', "level_up")
			usr << level_up_sound
			spawn(15)
			overlays = null

		death_check()
			if(health <= 0)
				is_dead = TRUE
				Text(src, "YOU DIED ", "red")

				underlays = null
				overlays = null
				if(poison_effect)
					poison_effect:remove_effect()

				icon = new/icon('icons/player_effects.dmi', "dead")

				for(var/mob/enemies/M in view())
					if(M.target == src)
						M.target = null
						M.current_state = M.WANDERING

				animate(src, alpha = 0, time = 40)
				spawn(40)
					loc=locate(12, 44, 1)
					dir = SOUTH
					icon = initial(icon)
					alpha = 255
					health = max_health
					update_bars()
					is_dead = FALSE


		take_damage(mob/enemies/M)
			attacked=TRUE
			var/damage = rand(M.power-3, M.power+3)

			damage > M.max_power ? s_damage(src, damage, "red") : s_damage(src, damage, "white")

			health -= damage
			src << hit_sound

			death_check()
			update_bars()

			spawn(8)
			attacked=FALSE

		update()
			if(is_poisoned)
				health -= rand(1, 8)
				death_check()
				update_bars()

			spawn(20)
			update()

	// Actions or commands
	verb
		Speak()
			set hidden = 1
			var/obj/emoticon/typing/EMO = new(null, -20, 15)
			overlays += EMO
			var/msg = input("", "Type Something")
			if(msg) world << "<font color = green> [client]: [msg]</font>"
			overlays -= EMO

		Attack()
			set hidden = 1
			if(attacking || is_dead) return
			attacking=TRUE
			for(var/mob/enemies/E in oview(1))
				if(get_dist(src,E)<=1)
					src.dir=get_dir(src,E)
					flick("attacking", src)
					var/icon/I = icon('icons/player.dmi', "sword")
					E.overlays += I
					E.take_damage(src)
					if(E)
						E.overlays -= I
			spawn(5)
			attacking=FALSE

		Bow()
			if(attacking || is_dead) return
			src << bow_shot
			attacking=TRUE
			new/obj/projectile/arrow(usr)
			spawn(5)
			attacking=FALSE

		Teleport()
			if(is_dead || teleported) return
			if(mana < 10) return
			mana -= 10

			update_bars()
			teleported=TRUE

			flick(new/icon('icons/Jesse.dmi', "teleport_out"), usr)
			sleep(0.5)
			for(var/turf/T in oview(3))
				if(istype(T,/turf))
					if(dir == SOUTH)
						if(T.y < y && T.x == x)
							x = T.x
							y = T.y
					if(dir == NORTH)
						if(T.y > y && T.x == x)
							x = T.x
							y = T.y
					if(dir == EAST)
						if(T.y == y && T.x > x)
							x = T.x
							y = T.y

					if(dir == WEST)
						if(T.y == y && T.x < x)
							x = T.x
							y = T.y
			sleep(0.5)
			flick(new/icon('icons/Jesse.dmi', "teleport_in"), usr)

			spawn(tele_cooldown)
			teleported=FALSE


obj
	shadow
		icon = 'icons/player.dmi'
		icon_state = "shadow"
		pixel_y = -3


obj/HUD
	health_bar
		icon = 'icons/player_health.dmi'
		icon_state = "10"
		screen_loc = "2, 2:8"

	mana_bar
		icon = 'icons/player_mana.dmi'
		icon_state = "10"
		screen_loc = "2, 2"

	exp_bar
		icon = 'icons/player_exp.dmi'
		icon_state = "1"
		screen_loc = "2:3, 1:17"