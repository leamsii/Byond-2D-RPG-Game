Player
	parent_type = /mob
	icon = 'icons/williams.dmi'
	icon_state = "player"

	Move() // Block movement if dead
		if(!current_state[DEAD])
			return ..()

	// Variables
	var
		// The maxes variables will be used to control the recovery of status effects
		health = 100
		max_health = 100
		power = 12
		max_power = 12
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
		sound
			level_up_sound = new/sound('sound/player/level_up.ogg', volume=30)
			hit_sound = new/sound('sound/player/hit.ogg', volume=30)
			bow_shot = new/sound('sound/player/bow_shot.wav', volume=20)
			effect_fire = new/sound('sound/player/effects_fire.wav')
			teleport_sound = new/sound('sound/player/teleport.ogg', volume=50)
			ability_sound = new/sound('sound/player/new_ability.wav', volume=50)
			healing_sound = new/sound('sound/player/heals.wav', volume=50)
			death_sound = new/sound('sound/player/death.wav', volume=100)

		// Effects
		status_effect = null

		// States
		const
			ATTACKING = 1
			DEAD = 2
			TELEPORTING = 3
			ATTACKED = 4
			LOW_HEALTH = 5
			INVISIBLE = 6

		list
			current_state[6]
			target_list = list()
			item_list = list()

		//Bars
		HUD/
			health_bar
			exp_bar
			mana_bar
			slot1

		// Skills

		ARCHER = FALSE
		TELB = FALSE
		INV = FALSE

		teleportout_icon = icon('icons/Jesse.dmi', "teleport_out")
		teleportin_icon = icon('icons/Jesse.dmi', "teleport_in")

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
			var/state = "[round((num-1)*min/max, 1) + 1]" // Get the percentage and scale it by number of states

			return state

		Update_Bar(args)
			if(health < 0) health = 0
			if(mana < 0) mana = 0

			for(var/barname in args)
				switch(barname)
					if("health")
						health_bar.icon_state = Get_Bar_State(health, max_health, 22)

					if("mana")
						mana_bar.icon_state = Get_Bar_State(mana, max_mana, 21)
					if("exp")
						exp_bar.icon_state = Get_Bar_State(exp, max_exp, 21)

		Give_EXP(amount)
			exp += amount
			Text(src, "+[amount] EXP ", "yellow")
			if(exp >= max_exp)
				Level_Up()

			Update_Bar(list("exp"))

		Level_Up()
			Text(src, "+LEVEL UP ", rgb(100, 255, 0))

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
				src << death_sound

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
						M.overlays -= M.health_bar
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

			for(var/HUD/circle_hud in client.screen)
				flick("circle_hud_active", circle_hud)

			// Knock back
			var/tmp_dir = dir
			for(var/i = 0; i < 5; i++)
				sleep(0.1)
				step_away(src, M, 5, speed)
				dir = tmp_dir

			health -= damage
			Show_Damage(src, damage, 12, 32)
			src << hit_sound

			Death_Check()

		Remove_Invisibility()
			for(var/Enemies/M in oview(0)) // If the player comes visible ontop of enemy
				Take_Damage(M)
				break

			alpha = 255
			density = 1

	// Actions or commands
	verb
		Speak(msg as text)
			if(msg)
				world << "<font color = green> [client]: [msg]</font>"


		Attack()
			set hidden = 1
			if(current_state[ATTACKING] || current_state[DEAD] || current_state[ATTACKED]) return

			for(var/Enemies/Target in oview(1))
				if(get_dist(src, Target) <= 2)
					Remove_Invisibility()
					Update_State(ATTACKING, 4)

					dir=get_dir(src,Target)
					flick("sword_attack", src)
					Target.Take_Damage(src)
					break

		PhaseWalk()
			if(current_state[DEAD] || current_state[INVISIBLE] || !INV) return
			Update_State(INVISIBLE, 40)
			for(var/i = 0; i < 20; i++)
				new/Particle/Smoke(src)

			alpha = 50
			density = 0
			sleep(40)
			Remove_Invisibility()

		Bow()
			if(current_state[ATTACKING] || current_state[DEAD] || !ARCHER) return

			flick("shoot_bow", src)
			Update_State(ATTACKING, 2)
			src << bow_shot

			new/Projectile/Arrow(usr)

		Teleport()
			if(current_state[TELEPORTING] || current_state[DEAD] || mana < 10 || !TELB) return

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

					flick(teleportout_icon, src)
					loc=nextloc
					flick(teleportin_icon, src)

HUD
	parent_type = /obj
	health_bar
		icon = 'icons/health_bar.dmi'
		icon_state = "22"
		screen_loc = "2:23, 10:18"
		New(client/c)
			..()
			c.screen += new/HUD/circle_hud()

	circle_hud
		icon = 'icons/williams.dmi'
		icon_state = "circle_hud"
		screen_loc = "1:5, 10"

	mana_bar
		icon = 'icons/mana_bar.dmi'
		icon_state = "21"
		screen_loc = "3:1, 10:15"

	exp_bar
		icon = 'icons/exp_bar.dmi'
		icon_state = "1"
		screen_loc = "3:1, 10:12"


Player/proc/
	Get_Item_Count(Item)
		var/item_count = 0
		for(var/I in item_list)
			if(Item:type == I:type)
				item_count += 1
		return item_count

	Add_Item(Item)
		item_list.Add(Item)

		if(!slot1:owner)
			Update_Amount(Get_Item_Count(Item))
			Add_Owner(Item)

		else if(slot1:owner:type == Item:type)
			Update_Amount(Get_Item_Count(Item))


	Add_Owner(Item)
		var/obj/O = new()
		O.icon = icon(Item:icon, Item:icon_state + "_static")
		O.pixel_y += 3
		slot1.overlays += O
		slot1:_icon = O
		slot1:owner = Item
		Item:ACTIVE = TRUE

	Remove_Item(Item)
		var/item_count = Get_Item_Count(Item) - 1
		Update_Amount(item_count)
		item_list.Remove(Item)

		if(slot1:owner == Item)
			if(item_count == 0) // If this was the last of its type
				slot1:owner = null
				slot1:overlays -= slot1:_icon

				// Replace it with the next item on the list
				for(var/I in item_list)
					Update_Amount(Get_Item_Count(I))
					Add_Owner(I)
					break

			else // If there are more than 1 of the same item in the list
				for(var/I in item_list)
					if(Item:type == I:type)
						slot1:owner = I
						I:ACTIVE = TRUE

	Update_Amount(item_count)
		// Remove old text from screen
		for(var/HUD/Item_Text/T in client.screen)
			del T

		if(item_count != 0)
			var/HUD/Item_Text/X = new(client)
			X.icon_state = "x"
			X.screen_loc = "16, 3"

			item_count = num2text(item_count)
			for(var/i = 1; i <= length(item_count); i++)
				var/HUD/Item_Text/T = new(client)
				T.icon_state = item_count[i]
				T.screen_loc = "16:[5 + (i * 6)], 3"

Player/verb/E()
	if(slot1:owner)
		slot1:owner:Use()

obj
	Healh_Effect
		icon = 'icons/large_effects.dmi'
		icon_state = "healwave2"

	Healh_Effect2
		icon = 'icons/large_effects.dmi'
		icon_state = "healwave"


HUD
	icon = 'icons/Jesse.dmi'
	Key_Slots
		var
			owner = null
			_icon = null

		New(client/c)
			..()
			c.screen += src

		Slot1
			icon_state = "key_slot"
			screen_loc = "15, 2"
			New(client/c)
				..(c)
				c:mob:slot1 = src
				var/HUD/Key_Slots/E_Key/Key = new()
				Key.pixel_y = -17
				overlays += Key

		E_Key
			icon_state = "key_e"
			screen_loc = "10, 1:10"


HUD
	Item_Text
		icon = 'icons/numbers.dmi'
		New(client/c)
			..()
			c.screen += src
