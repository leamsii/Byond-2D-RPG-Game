Projectile
	parent_type = /obj
	icon = 'icons/Jesse.dmi'
	density=1
	var
		owner = null
		flying_iconstate = ""
		stuck_iconstate = ""
		sound/arrow_stuck = sound('sound/player/arrow_stuck.wav')

	New(mob/M)
		..()
		owner = M
		dir=M.dir
		loc=M.loc
		step_x = M.step_x
		step_y = M.step_y

		// Set the bounds
		if(dir == NORTH || dir == SOUTH)
			bound_y = 3
			bound_height = 26
			bound_x = 13
			bound_width = 3
		else
			bound_x = 1
			bound_width = 10
			bound_height=  3
			bound_y = 12

		// Center the arrow
		if(dir == NORTH)
			step_x += 10
			step_y += 11
		if(dir == SOUTH)
			step_x += 5
			step_y -= 25
		if(dir == EAST)
			step_x += 25
			step_y += 1
		if(dir == WEST)
			step_x -= 25
			step_y += 1

		// Move the arrow
		walk(src, dir,  0, 7)
		icon_state = flying_iconstate

	Bump(mob/M)
		if(owner == M) del src
		if(istype(M,/Enemies) || istype(M,/Player))
			M:Take_Damage(owner)
			del src
		else if(!istype(M,/Item))
			icon_state = stuck_iconstate
			owner << arrow_stuck
			walk(src,null)
			density=0
		else
			del src

	Arrow
		icon_state = "arrowr"
		flying_iconstate = "arrowc_flying"
		New(mob/M)
			..(M)
			if(istype(M,/Player))
				icon_state = "arrowr"
				flying_iconstate = "arrowc_flying"
				stuck_iconstate  = "arrowc_stuck"
			else
				icon_state = "arrowb"
				flying_iconstate = "arrowb_flying"
				stuck_iconstate  = "arrowb_stuck"