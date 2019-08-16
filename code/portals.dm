Portal
	parent_type = /obj
	icon = 'icons/Jesse.dmi'
	icon_state = "portal"

	Crossed(Player/P)
		P << "Get out of here git"
		animate(P, alpha = 0, time= 10)
		alpha = 0
		sleep(10)
		P.alpha = 255
		P.loc = locate(12, 8, 1)