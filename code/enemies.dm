Enemies
	New()
		..()
		Set_Stats()

		current_state[WANDERING] = TRUE
		Wander()

	// Define the stats for the Enemies
	parent_type = /mob
	var
		//States
		const
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

		list/current_state = list(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)

		// Status
		health = 40
		max_health = 40
		max_power = 10
		power = 10
		speed = 1
		exp = 20
		level = 1
		obj/health_bar = null

		// Animations
		dying_animation = null
		dying_animation_delay = 0

		// Loot
		loot = null

		//Visual
		emoticon_x = 0
		emoticon_y = 0

		// Other
		status_effect = null
		current_target = null
		enemy_type = MEELEE
		attack_delay = 10

	// Define the Enemies bahaviors
	proc
		Set_Stats()
			power = max_power = rand(3, 10) + (level * 3)
			health = max_health = rand(20, 40) + (level * 20)
			exp = round((power + health) / 2)

		Drop_Item()
			// Drop a random Item from the loot list
			for(var/O in loot)
				if(prob(O:drop_rate))
					O:step_x = step_x
					O:step_y = step_y
					O:loc=loc

		Wander() // Wanders around aimlessly
			if(!current_state[WANDERING]) return
			walk_rand(src, 0, speed)
			spawn(rand(1, 10))
			walk(src, null)

			spawn(20) Wander()

		Take_Damage(Player/P)
			if(current_state[DYING] || !istype(P,/Player)) return

			if(!current_state[ATTACKING])
				new/Emoticon/Alert(src, emoticon_x, emoticon_y) // Alert emoticon
				current_state[ATTACKING] = TRUE
				current_state[WANDERING] = FALSE
				current_target = P

				if(!P.target_list.Find(src))
					P.target_list.Add(src)

				Follow_Target()

			flick("[name]_hurt", src)
			Play_Sound(P, name, "hit.wav")

			step_away(src, P, 10, speed * 2) // Knock Back

			var/damage = rand(P.power-5, P.power+2)
			damage > P.max_power ? s_damage(src,damage, "red") : s_damage(src,damage, "yellow")
			health -= damage

			if(health <= 0)
				Death(P)

		Death(Player/P) // Handles the death of enemies
			overlays = null
			walk(src, null)

			current_state[DYING] = TRUE
			current_state[WANDERING] = FALSE
			current_state[ATTACKING] = FALSE

			density=0
			icon_state = dying_animation
			Play_Sound(P, name, "death.wav")

			Drop_Item()
			P.Give_EXP(exp)

			if(name == "flower") animate(src, alpha=0,time = dying_animation_delay)

			// Remove it from map and delete
			sleep(dying_animation_delay)
			loc=locate(1, 1, -1)
			spawn(100) del src

		Follow_Target()
			if(!current_state[ATTACKING]) return
			if(current_target && get_dist(src, current_target) <= 6)
				Keep_Distance()
			else
				new/Emoticon/Question(src, emoticon_x, emoticon_y)
				current_state[WANDERING] = TRUE
				current_state[ATTACKING] = FALSE
				current_target = null
				Wander()

			spawn(5) Follow_Target()

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

	Bump(Player/P)
		if(enemy_type == ARCHER) return
		if(current_state[ATTACKING] && istype(P,/Player))
			if(!current_state[ATTACKED] && !P.current_state[P.DEAD] )
				current_state[ATTACKED] = TRUE

				// Handle for flower
				if(istype(src,/Enemies/Flower))
					flick("attack", src)

				sleep(1)
				P.Take_Damage(src)

				if(status_effect && P.status_effect == null) // Burnt and Poison effects
					if(prob(20))
						P.Apply_Effect(status_effect)

				spawn(attack_delay) current_state[ATTACKED] = FALSE

	Slime
		icon = 'icons/slime_sprites.dmi'
		icon_state = "slime1"
		name = "slime"

		// Bounds
		bound_width = 10
		bound_x = 5
		bound_y = 5
		bound_height = 10
		emoticon_x = -20
		emoticon_y = 15

		New()

			..()
			loot = list(new/Item/Gold(src, 60), new/Item/HP_Potion(src, 10), new/Item/MP_Potion(src, 10))

			level = rand(1, 2)
			dying_animation = icon_state + "_die"

		SlimeFire
			icon_state = "slime_fire"
			dying_animation_delay = 14
			level = 3
			status_effect = "burn"
		SlimePoison
			icon_state = "slime_poison"
			dying_animation_delay = 16
			status_effect = "poison"
		SlimeAcid
			icon_state = "slime_acid"
			dying_animation_delay = 8

		DummySlime2
			icon = 'icons/williams.dmi'
			icon_state = "slime_idle"

		Forest_Slime
			icon = 'icons/williams.dmi'
			icon_state = "forest_slime"
			name = "forest_slime"
			dying_animation_delay = 6
			New()
				..()
				dying_animation = "forest_slime_dying"


	Flower
		icon = 'icons/flower_enemy.dmi'
		icon_state = "flower"
		name = "flower"

		emoticon_x = -10
		emoticon_y = 55
		dying_animation_delay = 19
		level = 8
		dying_animation = "flower_dead"
		layer=MOB_LAYER+1

		// Bounds
		bound_width = 32
		bound_x = 12
		bound_y = 10
		bound_height = 12

		New()
			..()
			loot = list(new/Item/Gold(src, 100), new/Item/HP_Potion(src, 100), new/Item/MP_Potion(src, 100))
			underlays=null

	Monkey
		icon = 'icons/monkey.dmi'
		icon_state = "monkey"
		name = "monkey"

		level = 5
		speed = 2
		emoticon_x = -15
		emoticon_y = 20
		enemy_type = ARCHER

		New()
			..()
			loot = list(new/Item/Gold(src, 100), new/Item/HP_Potion(src, 100), new/Item/MP_Potion(src, 100))

// Handle Sounds
proc
	Play_Sound(target, enemy_name, sound_name, v=30)
		target << sound("sound/[enemy_name]/[sound_name]", volume=v, repeat=0)


Dummy
	icon = 'icons/dummy.dmi'
	icon_state = "dummy"
	parent_type = /obj

Whirl
	parent_type = /obj
	icon = 'icons/large_effects.dmi'
	icon_state = "whirlwind"