Particle
	parent_type = /obj
	icon = 'icons/particles.dmi'

	Goo
		icon_state = "goo1"
		layer = MOB_LAYER+1
		New(mob/M)
			if(prob(30))
				icon_state = "goo2"

			step_x = M.step_x
			step_y = M.step_y
			loc = M.loc
			var
				angle_x = 0
				angle_y = -5
				vel_x = rand(-2, 2)
				vel_y = rand(4, 6)

			animate(src, alpha = 0, time = 10 - vel_y)
			spawn(10 - vel_y) del src
			spawn(-1)
				while(src)
					sleep(0.1)
					pixel_x = sin(angle_x) * 50
					pixel_y = sin(angle_y) * 50

					angle_x += vel_x
					angle_y += vel_y