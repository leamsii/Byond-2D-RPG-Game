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
		health = 750
		max_health = 750

		power = 13
		max_power = 13

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
			ATTACKING = 1
			DEAD = 2
			TELEPORTING = 3

		list/current_state = list(FALSE, FALSE, FALSE) // 3 States
		list/target_list = list()

		//Bars
		HUD/
			health_bar = null
			exp_bar = null
			mana_bar = null
			shadow_underlay

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
					spawn(-1) Poison_Effect(20)
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

				flick("dying", src)
				icon_state = "dead"

				for(var/Enemies/M in target_list)
					if(M)
						M.current_target = null
						M.current_state[M.WANDERING] = TRUE
						M.current_state[M.ATTACKING] = FALSE
						M.Wander()

				target_list = list()

				//animate(src, alpha = 0, time = 40)
				spawn(40)
					loc=locate(12, 44, 1)
					dir = SOUTH
					icon_state = "player"
					alpha = 255
					health = max_health
					mana = max_mana

					Update_Bar(list("health", "mana"))

		Take_Damage(Enemies/M)
			if(current_state[DEAD]) return

			var/damage = rand(M.power-3, M.power+3)
			damage > M.max_power ? s_damage(src, damage, "red") : s_damage(src, damage, "white") // Critical hit

			health -= damage
			src << hit_sound

			Death_Check()

		Poison_Effect(amount)
			for(var/i=0;i < amount; i++)
				sleep(3.5)
				var/Particle/O = new(src, 0, 1, 0, 0)
				O.loc = loc
				O.icon_state = "poison2"
				spawn(-1) O.Fade(rand(5, 10))

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
				flick("sword_attack", src)
				target.Take_Damage(src)

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
					// Save the shadow
					underlays -= shadow_underlay

					Update_State(TELEPORTING, 5)

					//mana -= 10
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


Particle
	parent_type = /obj
	icon = 'icons/Status.dmi'
	layer = MOB_LAYER+1
	var
		angle_x = 0
		angle_y = 0
		xspeed = 0
		yspeed = 0

	New(Player/Owner, angle_x, angle_y, xspeed, yspeed)
		..()
		src.angle_x = angle_x
		src.angle_y = angle_y
		src.xspeed = xspeed
		src.yspeed = yspeed
		step_x = rand(Owner.step_x - 17, Owner.step_x + 10)
		step_y = rand(Owner.step_y - 20, Owner.step_y - 5)
		pixel_x = rand(-2, 2)

	proc
		Fade(delay)
			spawn(delay)
				icon_state = "poison3"
				sleep(1)
				del src
			while(src)
				pixel_x += angle_x
				pixel_y += angle_y
				sleep(0.1)