Player
	parent_type = /mob
	icon = 'icons/williams.dmi'
	icon_state = "player"

	Move() // Block movement if dead
		if(!current_state[DEAD])
			return ..()
	New()
		..()
		// HUD Bars
		//shadow_underlay = new/obj/shadow
		//underlays += shadow_underlay

	// Variables
	var
		// The maxes variables will be used to control the recovery of status effects
		health = 1000
		max_health = 1000

		power = 20
		max_power = 20

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
		sound/effect_fire = new/sound('sound/player/effects_fire.wav')
		sound/teleport_sound = new/sound('sound/player/teleport.ogg', volume=50)
		sound/ability_sound = new/sound('sound/player/new_ability.ogg', volume=50)

		// Effects
		status_effect = null

		// States
		const
			ATTACKING = 1
			DEAD = 2
			TELEPORTING = 3
			ATTACKED = 4
			LOW_HEALTH = 5

		list/current_state = list(FALSE, FALSE, FALSE, FALSE, FALSE) // 3 States
		list/target_list = list()

		//Bars
		HUD/
			health_bar = null
			exp_bar = null
			mana_bar = null
			shadow_underlay


		ARCHER = FALSE

	bound_y = 0
	bound_height = 30
	bound_x = 14
	bound_width = 24

	proc
		Update_State(state, delay)
			current_state[state] = TRUE
			spawn(delay) current_state[state] = FALSE

		Apply_Effect(effect)
			if(status_effect || current_state[DEAD]) return
			switch(effect)
				if("burn")
					src << effect_fire
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
			if(current_state[DEAD]) return
			if(health <= 0)
				Update_State(DEAD, 50)

				Text(src, "YOU DIED ", "red")

				// Remove BOSS health bars
				for(var/Health_Bar/H in client.screen)
					del H

				underlays = null
				overlays = null

				if(status_effect)
					status_effect:Remove_Effect(src)

				for(var/Enemies/M in target_list)
					if(M)
						M.current_target = null
						M.current_state[M.WANDERING] = TRUE
						M.current_state[M.ATTACKING] = FALSE
						M.Wander()

				target_list = list()

				flick("dying", src)
				icon_state = "dead"

				spawn(40)
					loc=locate(3, 8, 1)
					dir = SOUTH
					icon_state = "player"
					alpha = 255
					health = max_health
					mana = max_mana

					Update_Bar(list("health", "mana"))

		Take_Damage(Enemies/M)
			if(current_state[DEAD] || current_state[ATTACKED]) return
			Update_State(ATTACKED, 5)

			var/damage = rand(M.power-3, M.power+3)

			// Flinch
			if(!status_effect)
				for(var/i = 0; i < 1; i++)
					sleep(0.5)
					icon += rgb(255, 255, 255)
					sleep(1)
					icon = initial(icon)

			// Knock back
			var/tmp_dir = dir
			for(var/i = 0; i < 10; i++)
				sleep(0.1)
				step_away(src, M, 5, speed)
				dir = tmp_dir

			health -= damage
			Show_Damage(src, damage, 12, 32)
			src << hit_sound

			Death_Check()

	// Actions or commands
	verb
		Speak(msg as text)
			if(msg)
				world << "<font color = green> [client]: [msg]</font>"


		Attack()
			set hidden = 1
			if(current_state[ATTACKING] || current_state[DEAD] || current_state[ATTACKED]) return

			var/Enemies/target=null // Define a target
			for(var/Enemies/E in oview(1))
				if(get_dist(src,E) <= 2)
					target = E
					break

			if(target)
				Update_State(ATTACKING, 4)

				dir=get_dir(src,target)
				spawn(-1)
					flick("sword_attack", src)
					target.Take_Damage(src)

		Bow()
			if(current_state[ATTACKING] || current_state[DEAD] || !ARCHER) return
			for(var/Enemies/E in oview(1))
				src << "Too close to enemy!"
				return


			flick("shoot_bow", src)

			Update_State(ATTACKING, 2)

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
					// Save the shadow
					underlays -= shadow_underlay

					Update_State(TELEPORTING, 5)

					mana -= 10
					Update_Bar(list("mana"))
					src << teleport_sound

					flick(new/icon('icons/Jesse.dmi', "teleport_out"), src)
					sleep(1.4)
					loc=nextloc
					flick(new/icon('icons/Jesse.dmi', "teleport_in"), src)

					underlays += shadow_underlay

obj
	shadow
		icon = 'icons/player.dmi'
		icon_state = "shadow"
		pixel_y = -3


HUD
	parent_type = /obj
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