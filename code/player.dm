Player
	parent_type = /mob
	icon = 'icons/player.dmi'
	icon_state = "player"

	Move() // Block movement if dead
		if(!current_state[DEAD])
			return ..()
	New()
		..()
		// HUD Bars
		underlays += new/obj/shadow

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

		mana = 50
		max_mana = 50

		// Sounds
		sound/level_up_sound = new/sound('sound/player/level_up.ogg', volume=30)
		sound/hit_sound = new/sound('sound/player/hit.ogg', volume=30)
		sound/bow_shot = new/sound('sound/player/bow_shot.wav', volume=20)
		sound/teleport_sound = new/sound('sound/player/teleport.ogg', volume=50)

		// Effects
		status_effect = null

		// States
		const
			ATTACKED = 1
			ATTACKING = 2
			DEAD = 3
			TELEPORTING = 4

		list/current_state = list(FALSE, FALSE, FALSE, FALSE) // 5 States
		list/target_list = list()

		//Bars
		obj/
			health_bar = null
			exp_bar = null
			mana_bar = null

	proc
		Update_State(state, delay)
			current_state[state] = TRUE
			spawn(delay) current_state[state] = FALSE

		Apply_Effect(effect)
			if(status_effect || current_state[DEAD]) return
			switch(effect)
				if("burn")
					status_effect = new/Effect/Burning(src)
				if("poison")
					status_effect = new/Effect/Poison(src)

		Get_Bar_State(val, max_val, num)
			var/max = max(max_val,0.000001) // The larger value, or denominator
			var/min = min(max(val),max) // The smaller value, or numerator
			var/state = "[round((num-1)*min/max,1)+1]" // Get the percentage and scale it by number of states

			return state

		Update_Bar(args)
			if(health < 0) health = 0
			if(mana < 0) mana = 0

			for(var/barname in args)
				switch(barname)
					if("health")
						health_bar.icon_state = Get_Bar_State(health, max_health, 10)
					if("mana")
						mana_bar.icon_state = Get_Bar_State(mana, max_mana, 10)
					if("exp")
						exp_bar.icon_state = Get_Bar_State(exp, max_exp, 6)

		Give_EXP(amount)
			exp += amount
			Text(src, "+[amount] EXP ", "yellow")
			if(exp >= max_exp)
				Level_Up()

			Update_Bar(list("exp"))

		Level_Up()
			Text(src, "You leveled up! ")

			exp = 0
			max_exp *= 2
			max_power += 3
			power = max_power
			health += max_health / 2
			mana += max_mana / 2

			if(health > max_health)
				health = max_health
			if(mana > max_mana)
				mana = max_mana

			max_health += 20
			max_mana += 20

			Update_Bar(list("health", "mana", "exp"))

			overlays += icon('icons/Jesse.dmi', "level_up")
			usr << level_up_sound


			spawn(15)
			overlays = null

		Death_Check()
			Update_Bar(list("health", "exp"))
			if(health <= 0)
				Update_State(DEAD, 40)

				Text(src, "YOU DIED ", "red")

				underlays = null
				overlays = null

				if(status_effect)
					status_effect:Remove_Effect(src)

				icon = new/icon('icons/player_effects.dmi', "dead")

				for(var/Enemies/M in target_list)
					if(M)
						M.current_target = null
						M.current_state[M.WANDERING] = TRUE
						M.current_state[M.ATTACKING] = FALSE
						M.Wander()

				target_list = list()

				animate(src, alpha = 0, time = 40)
				spawn(40)
					loc=locate(12, 44, 1)
					dir = SOUTH
					icon = initial(icon)
					alpha = 255
					health = max_health
					mana = max_mana

					Update_Bar(list("health", "mana"))

		Take_Damage(Enemies/M)
			if(current_state[ATTACKED] || current_state[DEAD]) return
			Update_State(ATTACKED, 8)

			var/damage = rand(M.power-3, M.power+3)
			damage > M.max_power ? s_damage(src, damage, "red") : s_damage(src, damage, "white") // Critical hit

			health -= damage
			src << hit_sound

			Death_Check()

	// Actions or commands
	verb
		Speak()
			set hidden = 1
			var/Emoticon/Typing/EMO = new(null, -20, 15)
			overlays += EMO
			var/msg = input("", "Type Something")
			if(msg) world << "<font color = green> [client]: [msg]</font>"
			overlays -= EMO

		Attack()
			set hidden = 1

			if(current_state[ATTACKING] || current_state[DEAD]) return

			var/Enemies/target=null // Define a target
			for(var/Enemies/E in oview(1))
				if(get_dist(src,E)<=1)
					target = E
					break

			if(target)
				Update_State(ATTACKING, 4)

				dir=get_dir(src,target)
				flick("attacking", src)
				var/icon/I = icon('icons/player.dmi', "sword")

				target.overlays += I
				target.Take_Damage(src)
				target.overlays -= I

		Bow()
			if(current_state[ATTACKING] || current_state[DEAD]) return
			Update_State(ATTACKING, 5)

			src << bow_shot
			new/Projectile/Arrow(usr)

		Teleport()
			if(current_state[TELEPORTING] || current_state[DEAD] || mana < 10) return

			var/turf/nextloc = null
			if(dir == SOUTH)
				nextloc = locate(x, y-3, z)
			if(dir == NORTH)
				nextloc = locate(x, y+3, z)
			if(dir == EAST)
				nextloc = locate(x+3, y, z)
			if(dir == WEST)
				nextloc = locate(x-3, y, z)

			if(isturf(nextloc))
				if(nextloc.density==0)
					Update_State(TELEPORTING, 5)

					mana -= 10
					Update_Bar(list("mana"))
					src << teleport_sound

					flick(new/icon('icons/Jesse.dmi', "teleport_out"), src)
					sleep(1)
					loc=nextloc
					sleep(1)
					flick(new/icon('icons/Jesse.dmi', "teleport_in"), src)

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