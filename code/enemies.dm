Enemies
	New()
		..()
		Set_Stats()
		if(BOSS)
			health_bar = new/Health_Bar()
		else
			health_bar = new/Mini_Bar(src, 9, 30)

		current_state[WANDERING] = TRUE
		Wander()

	// Define the stats for the Enemies
	parent_type = /mob
	var
		const
			// States
			WANDERING = 1
			ATTACKING = 2
			FOLLOWING = 3
			DYING = 4
			IDLE = 5
			SHOOTING = 6
			ATTACKED = 7

			// Type of enemies
			MEELEE = 0
			ARCHER = 1

			//Animation
			DYING_ANIMATION = 1

		list
			target_list = list()
			animation_delays = list(0)


		current_state[7]
		loot = null
		health_bar = null

		// Status
		health = 40
		max_health = 40
		max_power = 10
		power = 10
		speed = 1
		exp = 20
		level = 1

		emoticon_x = 0
		emoticon_y = 0
		status_effect = null
		current_target = null
		enemy_type = MEELEE
		attack_delay = 10
		BOSS = FALSE
		view_range = 6

		sound/golem_roar = sound('sound/golem/roar.wav')

	// Define the Enemies bahaviors
	proc
		Set_Stats()
			power = max_power = rand(3, 10) + (level * 2)
			health = max_health = rand(20, 40) + (level * 20)
			exp = round((power + health) / 2)

		Drop_Item(Player/P)
			// Drop a random Item from the loot list
			var
				Item/I
				item_type = -1
				drop_rate = 0

			for(var/i = 1; i < length(loot); i++)
				item_type = loot[i]
				drop_rate = loot[i+1]

				if(prob(drop_rate))
					switch(item_type)
						if(GOLD_ID)
							I = new/Item/Gold(src)
						if(HP_POTION_ID)
							I = new/Item/HP_Potion()
						if(MP_POTION_ID)
							I = new/Item/MP_Potion()
						if(TEL_AB)
							I = new/Item/Ability/Teleport()
						if(BOW_AB)
							I = new/Item/Ability/Bow()
						if(INV_AB)
							I = new/Item/Ability/Invisible()
					if(I)
						I.step_x = step_x + rand(-4, 4)
						I.step_y = step_y
						I.loc = loc
						if(istype(I,/Item/Ability))
							break

		Wander() // Wanders around aimlessly
			if(!current_state[WANDERING]) return

			for(var/Player/P in view(8))
				walk_rand(src, 0, speed)
				spawn(rand(1, 10))
				walk(src, null)
				if(BOSS && !P.current_state[P.DEAD])
					Take_Damage(P)
				break

			spawn(20) Wander()

		Take_Damage(Player/P)
			if(current_state[DYING]) return

			// First time being hit
			if(!current_state[ATTACKING])
				new/Emoticon/Alert(src, emoticon_x, emoticon_y) // Alert emoticon
				current_state[ATTACKING] = TRUE
				current_state[WANDERING] = FALSE
				current_target = P

				// Add targetlist for player
				if(!P.target_list.Find(src))
					P.target_list.Add(src)

				if(BOSS)
					P << golem_roar
				else
					overlays += health_bar

				Follow_Target()

			// Add to target list
			if(!target_list.Find(P))
				target_list.Add(P)

			flick("[icon_state]_hurt", src)
			Play_Sound(P, name, "hit.wav")
			step_away(src, P, 10, speed * 2) // Knock Back
			var/damage = rand(P.power-5, P.power+2)
			health -= damage
			Update_Health()
			Show_Damage(src, damage, 10, 24)

			if(health <= 0)
				Death(P)

		Death(Player/P) // Handles the death of enemies
			walk(src, null)

			current_state[DYING] = TRUE
			current_state[WANDERING] = FALSE
			current_state[ATTACKING] = FALSE
			density=0

			if(BOSS) // If this enemy was a boss, remove the boss health bar from screen
				for(var/Player/PP in target_list)
					for(var/Health_Bar/H in PP.client.screen)
						del H
				new/Portal(loc)

			// Drop an item, give exp play dying sound and show hurt animation
			flick(icon_state + "_die", src)
			Play_Sound(P, name, "death.wav")
			Drop_Item(P)
			P.Give_EXP(exp)



			// Generate particles
			spawn(-1)
				for(var/i = 0; i < 10; i++)
					new/Particle/Goo(src)


			// Remove it from map and delete
			sleep(animation_delays[DYING_ANIMATION])
			del src

		Follow_Target()
			if(!current_state[ATTACKING]) return
			if(current_target && get_dist(src, current_target) <= view_range)
				Keep_Distance()
			else
				if(!BOSS) // Bosses won't lose the player
					new/Emoticon/Question(src, emoticon_x, emoticon_y)
					current_state[WANDERING] = TRUE
					current_state[ATTACKING] = FALSE
					current_target = null
					overlays -= health_bar
					Wander()

			spawn(15) Follow_Target()

		Keep_Distance()
			if(enemy_type == ARCHER)
				if(get_dist(src, current_target) < 2)
					walk_away(src, current_target, 3,0, speed)
				else
					walk_to(src, current_target, 2, 0, speed)
					Shoot()
			else
				walk_to(src, current_target, -1, 0, speed)

		Shoot()
			if(current_state[SHOOTING]) return
			current_state[SHOOTING] = TRUE
			new/Projectile/Arrow(src)
			spawn(15) current_state[SHOOTING] = FALSE


		Update_Health()

			var/state = Get_Bar_State(health, max_health, BOSS ? 30 : 15)

			if(BOSS)
				if(current_target)
					var/has_bar = FALSE
					for(var/Health_Bar/O in current_target:client:screen)
						O.icon_state = state
						has_bar = TRUE

					if(!has_bar)
						var/Health_Bar/H = new()
						H.alpha = 0
						animate(H, alpha = 255, time = 5)
						H.icon_state = state
						current_target:client:screen += H
			else
				overlays -=health_bar
				health_bar:icon_state = state
				overlays += health_bar

		Get_Bar_State(val, max_val, num)
			var/max = max(max_val,0.000001) // The larger value, or denominator
			var/min = min(max(val),max) // The smaller value, or numerator
			var/state = "[round((num-1)*min/max,1)+1]" // Get the percentage and scale it by number of states

			return state

	Bump(Player/P)
		if(enemy_type == ARCHER) return
		if(current_state[ATTACKING] && istype(P,/Player))
			if(!current_state[ATTACKED] && !P.current_state[P.DEAD] )
				current_state[ATTACKED] = TRUE

				sleep(1)
				P.Take_Damage(src)

				if(status_effect && P.status_effect == null) // Burnt and Poison effects
					if(prob(30))
						P.Apply_Effect(status_effect)

				spawn(attack_delay) current_state[ATTACKED] = FALSE
		else
			return

	Slime
		icon = 'icons/slime_sprites.dmi'
		icon_state = "slime1"
		name = "slime"

		// Bounds
		bound_width = 23
		bound_x = 14
		bound_y = 0
		bound_height = 20
		emoticon_x = -20
		emoticon_y = 15
		loot = list(GOLD_ID, 50, HP_POTION_ID, 20, MP_POTION_ID, 10)
		level = 1

		SlimeFire
			icon = 'icons/williams.dmi'
			icon_state = "slime_fire"
			status_effect = "burn"
			level = 3

		SlimePoison
			icon = 'icons/williams.dmi'
			icon_state = "slime_poison"
			status_effect = "poison"
			level = 4
			New()
				..()
				animation_delays[DYING_ANIMATION] = 1

		SlimeAcid
			icon_state = "slime_acid"
			New()
				..()
				animation_delays[DYING_ANIMATION] = 8

		Forest_Slime
			icon = 'icons/williams.dmi'
			icon_state = "forest_slime"
			New()
				..()
				animation_delays[DYING_ANIMATION] = 3

	Golem
		icon = 'icons/golem.dmi'
		icon_state = "golem"
		name = "golem"
		emoticon_x = -10
		emoticon_y = 50
		bound_y = 4
		bound_height = 35
		bound_x = 10
		bound_width = 40
		level = 10
		speed = 1
		view_range = 20
		BOSS = TRUE
		loot = list(GOLD_ID, 100, HP_POTION_ID, 100, MP_POTION_ID, 100)


// Handle Sounds
proc
	Play_Sound(target, enemy_name, sound_name, v=50)
		target << sound("sound/[enemy_name]/[sound_name]", volume=v, repeat=0)



Health_Bar
	parent_type = /obj
	icon = 'icons/boss_health_bar.dmi'
	icon_state = "29"
	screen_loc = "7, 11"


Mini_Bar
	parent_type = /obj
	layer = MOB_LAYER+1
	icon = 'icons/enemy_health.dmi'
	icon_state = "14"
	New(mob/M, pixel_x, pixel_y)
		src.pixel_x = pixel_x
		src.pixel_y = pixel_y