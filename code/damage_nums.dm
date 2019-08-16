Damage_Number
	parent_type = /obj
	icon = 'icons/damage_nums.dmi'
	layer = MOB_LAYER+1
	New(mob/M, state, xoffset=0, yoffset=0)
		..()
		icon_state = state
		step_x = M.step_x + xoffset
		step_y = M.step_y + yoffset
		loc = M.loc

		icon+=rgb(255, 100 ,0)


		animate(src, alpha = 0, time = 10)
		spawn(10) del src
		spawn(-1)
			while(src)
				sleep(0.1)
				pixel_y += 1

proc
	Show_Damage(mob/M, damage, xoffset=0, yoffset=0)
		damage = num2text(damage)
		for(var/i = 1; i <= length(damage); i++)
			new/Damage_Number(M, damage[i], xoffset + ((i - 1) * 7), yoffset)