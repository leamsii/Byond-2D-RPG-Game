mob/enemies
	// Define the stats for the enemies
	var
		//States
		const
			WANDERING = 0
			ATTACKING = 1
			FOLLOWING = 2
			DYING = 3
			IDLE = 4


		health = 100
		max_health = 100
		obj/health_bar = null
		power = 10
		defense = 4
		speed = 1
		exp = 20
		level = 2
		die_animation_delay = 0
		current_state = 0
		loot = list(new/obj/item/gold)
		sound/hit_sound = new/sound('sound/slime/hit.wav')
		sound/explode_sound = new/sound('sound/slime/explode.wav')

	// Define the enemies bahaviors
	proc
		drop_item()
			// Drop a random item from the loot list
			for(var/O in loot)
				if(prob(O:drop_rate))
					O:step_x = step_x
					O:step_y = step_y
					O:loc=loc

		wander() // Wanders around aimlessly
			if(current_state == WANDERING)
				walk(src, FALSE)
				walk(src, rand(1, 4), 0, speed)
				spawn(10)
				walk(src, FALSE) // Pause

		update_health_bar() // This will add the health bars to the enemies when they spawn
			var/max = max(max_health,0.000001) // The larger value, or denominator
			var/min = min(max(health),max) // The smaller value, or numerator
			var/state = "[round((14-1)*min/max,1)+1]" // Get the percentage and scale it by number of states

			overlays -= health_bar
			health_bar.icon_state = "[state]"
			overlays += health_bar

		take_damage(mob/player/P)

			if(current_state == DYING) return
			current_state = ATTACKING

			var/icon/I = icon('icons/player.dmi', "sword")
			overlays += I
			flick("slime_hurt", src)
			P << hit_sound

			knock_back(P)
			var/damage = rand(P.power-5, P.power+2)
			if(prob(20))
				s_damage(src,damage, "red")
			else
				s_damage(src,damage, "yellow")
			health -= damage

			// Update the health bar
			//update_health_bar()

			if(health <= 0)
				die(P)

			spawn(5)
			overlays -= I


		die(mob/player/P)
			overlays = null
			walk(src, null)
			current_state = DYING
			density=0
			flick(icon_state+"_die", src)
			drop_item()
			P.give_exp(rand(exp-5, exp+5))
			sleep(die_animation_delay)
			loc=locate(1, 1, -1) // Vanish it
			del src


		knock_back(mob/player/P)
			step_away(src, P, 10, speed * 2)

		update()
			if(current_state == WANDERING)
				wander()
			if(current_state == IDLE)
				walk(src, null)

			if(current_state == ATTACKING)
				attack()

			spawn(20)
			update()

		attack()
			if(current_state == ATTACKING)
				for(var/mob/player/P in view(5))
					walk_to(src, P, -1, 0, speed)

	New()
		..() // Call parent New
		var/obj/shadow/S = new()
		S.pixel_y = -4
		S.pixel_x = -2
		underlays += S
		current_state = WANDERING
		update()

	Bump(mob/player/P)
		if(current_state==ATTACKING && istype(P,/mob/player))
			if(!P.attacked)
				step_away(P, src, 2,P.speed * 2)
				P.take_damage(power)

	slime
		icon = 'icons/slime_sprites.dmi'
		icon_state = "slime1"

		slime_fire
			icon_state = "slime_fire"
			die_animation_delay = 14
			New()
				..()
				loot += new/obj/item/chest
		slime_poison
			icon_state = "slime_poison"
			die_animation_delay = 16
			New()
				overlays += icon('icons/Status.dmi', "poison2")
				..()
		slime_acid
			icon_state = "slime_acid"
			die_animation_delay = 8
			New()
				..()
				overlays += icon('icons/Status.dmi', "regen")