Projectile
	parent_type = /obj
	icon = 'icons/Jesse.dmi'
	density=1

	Arrow
		icon_state = "arrowr"
		var
			owner = null

		New(mob/M)
			..()
			if(istype(M,/Player))
				owner = M
				dir=M.dir
				loc=M.loc
				step_x = M.step_x
				step_y = M.step_y

			// Set the bounds
			if(dir == NORTH || dir == SOUTH)
				bound_y = 12
				bound_height = 18
				bound_x = 14
				bound_width = -4
			else
				bound_x = 10
				bound_width = 10
				bound_height=  0
				bound_y = 23

			// Center the arrow
			if(dir == NORTH)
				step_x -=1
				step_y += 11
			if(dir == SOUTH)
				step_x -= 6
				step_y -= 20
			if(dir == EAST)
				step_x += 10
				step_y -= 10
			if(dir == WEST)
				step_x -= 10
				step_y -= 10

			// Move the arrow
			walk(src, dir,  0, 7)
			icon_state = "arrowr_flying"

		Bump(mob/M)
			if(istype(M,/Enemies))
				M:Take_Damage(owner)
				del src
			else if(!istype(M,/Item) && !istype(M,/Player))
				icon_state = "arrowr_stuck"
				walk(src,null)
				density=0
			else
				del src

