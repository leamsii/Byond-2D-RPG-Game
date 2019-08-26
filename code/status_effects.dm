Effect
	parent_type = /obj
	icon = 'icons/Status.dmi'
	layer = MOB_LAYER+1
	var
		_color = null
		delay = 70
		power = 4

	proc
		Remove_Effect(Player/P)
			P.overlays -= src
			P.icon = initial(P.icon)
			P.status_effect = null
			del src

		Take_Damage(Player/P)
			while(usr)
				sleep(10)
				P.health -= power
				P.Death_Check()
				if(P.current_state[P.DEAD]) break

	New(Player/P)
		P.overlays += src
		P.icon += _color

		spawn(delay) Remove_Effect(P)
		spawn() Take_Damage(P)



	Poison
		icon_state = "poison2"
		pixel_x = 11
		pixel_y = -5
		_color = rgb(100, 0, 125)

	Burning
		icon_state = "burning2"
		pixel_x = 10
		pixel_y = 6
		_color = rgb(255, 0, 0)