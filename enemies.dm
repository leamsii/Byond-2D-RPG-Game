mob/enemies
	icon = 'enemies.dmi'
	// Define the stats for the enemies
	var
		health = 100
		max_health = 100
		attack = 10
		defense = 4
		speed = 1
		exp = 20
		health_bar = null
		level = 2

	// Define the enemies bahaviors
	proc
		wander() // Wanders around aimlessly
			walk(src, rand(1, 4), 0, speed)
			spawn(10)
			walk(src, FALSE) // Pause
			spawn(20)
			wander()

		add_health_bar() // This will add the health bars to the enemies when they spawn
			overlays=null
			var/max = max(max_health,0.000001) // The larger value, or denominator
			var/min = min(max(health),max) // The smaller value, or numerator
			var/state = "[round((14-1)*min/max,1)+1]" // Get the percentage and scale it by number of states

			var/obj/O = new()
			O.icon = 'health_bars.dmi'
			O.icon_state = "[state]"
			O.layer = MOB_LAYER+1
			O.pixel_y = 15
			O.pixel_x = -5
			overlays += O

		take_damage(mob/player/P)
			knock_back(P)
			var/damage = rand(P.power-5, P.power+2)
			P << "You hit [src] for [damage] damage"
			health -= damage
			// Update the health bar
			add_health_bar()

			if(health <= 0)
				die(P)

			// Flash animation
			flick("hurt", src)

		die(mob/player/P)
			P << "You earned [exp] EXP!"
			loc=locate(1, 1, -1) // Vanish it
			spawn(20)
			del src

		knock_back(mob/player/P)
			walk(src, P.dir, speed)

	New()
		..() // Call parent New
		add_health_bar()
		wander()

	slime
		icon_state = "slime1"
		New()
			..()
			if(prob(50)) // 50% change of it being fire
				icon_state = "slime2"
			if(prob(10)) // 10% change of it being poison
				icon_state = "slime3"