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

		// Status
		health = 100
		max_health = 100
		power = 10
		defense = 4
		speed = 1
		exp = 20
		level = 2
		obj/health_bar = null

		// Animations
		dying_animation = null
		die_animation_delay = 0
		current_state = 0

		// Loot
		loot = list(new/obj/item/gold, new/obj/item/HP_Potion)

		//Visual
		emoticon_x = 0
		emoticon_y = 0

		// Sound
		sound/hit_sound = new/sound('sound/slime/hit.wav', volume=30)
		sound/explode_sound = new/sound('sound/slime/explode.wav', volume=30)

	// Define the enemies bahaviors
	proc
		add_star(difficulty, pixel_x, pixel_y)
			for(var/i = 0;i < difficulty; i++)
				var/obj/star/S = new()
				S.pixel_y = pixel_y
				S.pixel_x = pixel_x + (i * 6)
				overlays+=S
		drop_item()
			// Drop a random item from the loot list
			for(var/O in loot)
				if(prob(O:drop_rate))
					O:step_x = step_x
					O:step_y = step_y
					O:loc=loc

					if(istype(O, /obj/item/gold))
						flick("coin_drop", O)

		wander() // Wanders around aimlessly
			if(current_state == WANDERING)
				walk(src, rand(1, 4), 0, speed)
				spawn(rand(5, 20))
				walk(src, FALSE) // Pause

		update_health_bar(pixel_x=0, pixel_y=0) // This will add the health bars to the enemies when they spawn
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

		take_damage(mob/player/P)

			if(current_state == DYING) return
			if(current_state != ATTACKING)
				new/obj/emoticon/alert(src, emoticon_x, emoticon_y)
				current_state = ATTACKING

			var/icon/I = icon('icons/player.dmi', "sword")
			overlays += I
			flick("[name]_hurt", src)
			P << hit_sound

			knock_back(P)
			var/damage = rand(P.power-5, P.power+2)
			if(prob(20))
				s_damage(src,damage, "red")
			else
				s_damage(src,damage, "yellow")
			health -= damage
			update_health_bar()

			if(health <= 0)
				die(P)

			spawn(5)
			overlays -= I


		die(mob/player/P)
			overlays = null
			walk(src, null)
			current_state = DYING
			density=0
			flick(dying_animation, src)
			P << explode_sound
			drop_item()
			P.give_exp(rand(exp-5, exp+5))
			if(name == "flower") animate(src, alpha=0,time = die_animation_delay)
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
				var/target=null
				for(var/mob/player/P in oview(3))
					target=P

				if(target)
					walk_to(src, target, -1, 0, speed)
				else
					new/obj/emoticon/question(src, emoticon_x, emoticon_y)
					current_state = WANDERING

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
				if(istype(src,/mob/enemies/slime/slime_fire))
					flick(new/icon('icons/player_effects.dmi', "burnt"), P)

				step_away(P, src, 2,P.speed * 2)
				P.take_damage(power)
		if(istype(P,/turf))
			if(current_state == WANDERING)
				walk(src, rand(1, 4), 0, speed)

	slime
		icon = 'icons/slime_sprites.dmi'
		icon_state = "slime1"
		bound_width = 10
		bound_x = 5
		emoticon_x = -20
		emoticon_y = 15
		name = "slime"
		New()
			..()
			dying_animation = icon_state + "_die"
			update_health_bar(-6, 10)
			add_star(1, -10, 12)

		slime_fire
			icon_state = "slime_fire"
			die_animation_delay = 14
			power = 15
			health = 200
			level = 5
			exp = 40
			New()
				..()
				add_star(3, -10, 12) // Tough enemy

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

	flower
		icon = 'icons/flower_enemy.dmi'
		icon_state = "flower"
		name = "flower"
		emoticon_x = -10
		emoticon_y = 55
		die_animation_delay = 19
		level = 10
		exp = 100
		power = 30
		health = 400
		dying_animation = "flower_dead"

		New()
			..()
			underlays=null
			update_health_bar(11, 52)
			add_star(5, 0, 55) // Boss

obj/star
	icon = 'icons/health_bars.dmi'
	icon_state = "star"
	layer=MOB_LAYER+8