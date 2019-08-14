Particle
	parent_type = /obj
	icon = 'icons/particles.dmi'

	Goo
		icon_state = "goo1"
		New(mob/M)
			if(prob(30))
				icon_state = "goo2"

			loc = M.loc
			step_x = M.step_x
			step_y = M.step_y

			spawn(5) del src

			var
				angle_x = 0
				angle_y = 0
				vel_x = rand(-2, 2)
				vel_y = 6


			while(src)
				sleep(0.1)
				pixel_x = cos(angle_x) * 100
				pixel_y = sin(angle_y) * 50

				angle_x += vel_x
				angle_y += vel_y