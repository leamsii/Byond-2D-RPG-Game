Particle
	parent_type = /obj
	icon = 'icons/particles.dmi'

	Smoke
		icon_state = "smoke1"
		layer = MOB_LAYER+1
		New(mob/M)
			if(prob(30))
				icon_state = "smoke2"
			if(prob(20))
				icon_state = "smoke3"

			step_x = M.step_x + rand(-15, 15)
			step_y = M.step_y + 20 + rand(-10, 10)

			loc = M.loc
			var
				angle_x = 5
				angle_y = -5
				vel_x = rand(-10, 10) / 10
				vel_y = rand(1, 3) / 10

			animate(src, alpha = 0, time = 8 - vel_y)
			spawn(8 - vel_y) del src
			spawn(-1)
				while(src)
					sleep(0.1)
					pixel_x = cos(angle_x) * 10
					pixel_y = sin(angle_y) * 300

					angle_x += vel_x
					angle_y += vel_y

	Goo
		icon_state = "goo1"
		layer = MOB_LAYER+1
		New(mob/M)
			if(prob(30))
				icon_state = "goo2"

			// Handle for different type of goos
			if(istype(M,/Enemies/Slime/SlimeFire))
				if(prob(30))
					icon_state = "fire_goo2"
				else
					icon_state = "fire_goo1"

			if(istype(M,/Enemies/Slime/SlimePoison))
				if(prob(30))
					icon_state = "poison_goo"
				else
					icon_state = "poison_goo2"

			if(istype(M,/Enemies/Golem))
				if(prob(30))
					icon_state = "golem1"
				else
					icon_state = "golem2"

			step_x = M.step_x
			step_y = M.step_y
			loc = M.loc
			var
				angle_x = 0
				angle_y = -5
				vel_x = rand(-2, 2)
				vel_y = rand(3, 5)

			animate(src, alpha = 0, time = 10 - vel_y)
			spawn(10 - vel_y) del src
			spawn(-1)
				while(src)
					sleep(0.1)
					pixel_x = sin(angle_x) * 50
					pixel_y = sin(angle_y) * 50

					angle_x += vel_x
					angle_y += vel_y