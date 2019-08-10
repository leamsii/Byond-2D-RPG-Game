Enemies
	New()
		..()
		var/obj/shadow/S = new()
		S.pixel_y = -4
		S.pixel_x = -2
		underlays += S
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
			POSITIONING = 6

			// Type of enemies
			MEELEE = 0
			ARCHER = 1

		list/current_state = list(TRUE, FALSE, FALSE, FALSE, FALSE)

		// Status
		health = 40
		max_health = 40
		max_power = 10
		power = 10
		speed = 1
		exp = 20
		level = 1
		difficulty = 1
		obj/health_bar = null

		// Animations
		dying_animation = null
		dying_animation_delay = 0

		// Loot
		loot = null

		//Visual
		emoticon_x = 0
		emoticon_y = 0

		// Sound
		sound/hit_sound = new/sound('sound/slime/hit.wav', volume=30)
		sound/explode_sound = new/sound('sound/slime/explode.wav', volume=30)

		// Other
		status_effect = null
		current_target = null
		enemy_type = MEELEE

	// Define the Enemies bahaviors
	proc
		Set_Stats()
			power = max_power = rand(3, 10) + (level * 3)
			health = max_health = rand(20, 40) + (level * 20)
			exp = round((power + health) / 2)

		Add_Stars(difficulty, pixel_x, pixel_y)
			for(var/i = 0;i < difficulty; i++)
				var/obj/star/S = new()
				S.pixel_y = pixel_y
				S.pixel_x = pixel_x + (i * 6)
				overlays+=S

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

		Update_Health(pixel_x=0, pixel_y=0) // This will add the health bars to the Enemies when they spawn
			if(!health_bar)
				//Add health bar
				var/obj/O = new()
				O.icon = 'icons/health_bars.dmi'
				O.icon_state = "8"
				health_bar = O
				O.layer = MOB_LAYER+1
				O.pixel_y = pixel_y
				O.pixel_x = pixel_x
				overlays += O

			var/max = max(max_health,0.000001) // The larger value, or denominator
			var/min = min(max(health),max) // The smaller value, or numerator
			var/state = "[round((8-1)*min/max,1)+1]" // Get the percentage and scale it by number of states

			overlays -= health_bar
			health_bar.icon_state = "[state]"
			overlays += health_bar

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
			P << hit_sound

			step_away(src, P, 10, speed * 2) // Knock Back

			var/damage = rand(P.power-5, P.power+2)
			damage > P.max_power ? s_damage(src,damage, "red") : s_damage(src,damage, "yellow")
			health -= damage
			Update_Health()

			if(health <= 0)
				Death(P)

		Death(Player/P) // Handles the death of enemies
			overlays = null
			walk(src, null)

			current_state[DYING] = TRUE
			current_state[WANDERING] = FALSE
			current_state[ATTACKING] = FALSE

			density=0
			flick(dying_animation, src)

			P << explode_sound

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
			new/Projectile/Arrow(src)

	Bump(Player/P)
		if(enemy_type == ARCHER) return
		if(current_state[ATTACKING] && istype(P,/Player))
			if(!P.current_state[P.ATTACKED] && !P.current_state[P.DEAD] )

				// If hit by fire slime, play burnt icon effect
				if(istype(src,/Enemies/Slime/SlimeFire))
					flick(new/icon('icons/player_effects.dmi', "burnt"), P)

				step_away(P, src, 2,P.speed * 2) // Knock back for player
				P.Take_Damage(src)

				if(status_effect && P.status_effect == null) // Burnt and Poison effects
					if(prob(20))
						P.Apply_Effect(status_effect)

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
			Update_Health(-6, 10)
			Add_Stars(difficulty, -10, 12)

		SlimeFire
			icon_state = "slime_fire"
			dying_animation_delay = 14
			level = 3
			difficulty = 2
			status_effect = "burn"
		SlimePoison
			icon_state = "slime_poison"
			dying_animation_delay = 16
			status_effect = "poison"
		SlimeAcid
			icon_state = "slime_acid"
			dying_animation_delay = 8

	Flower
		icon = 'icons/flower_enemy.dmi'
		icon_state = "flower"
		name = "flower"
		emoticon_x = -10
		emoticon_y = 55
		dying_animation_delay = 19
		level = 8
		difficulty = 5
		dying_animation = "flower_dead"
		hit_sound = new/sound('sound/flower/hit.ogg',volume=30)
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
			Update_Health(11, 52)
			Add_Stars(5, 0, 55)

	Skeleton
		icon = 'icons/skeleton.dmi'
		icon_state = "skeleton"
		level = 5
		speed = 2
		difficulty = 3
		emoticon_x = -15
		emoticon_y = 20
		enemy_type = ARCHER

		New()
			..()
			loot = list(new/Item/Gold(src, 100), new/Item/HP_Potion(src, 100), new/Item/MP_Potion(src, 100))
			Update_Health(-3, 16)
			Add_Stars(difficulty, -8, 16)

obj/star
	icon = 'icons/health_bars.dmi'
	icon_state = "star"
	layer=MOB_LAYER+8