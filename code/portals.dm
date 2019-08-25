Portal
	parent_type = /obj
	icon = 'icons/portal.dmi'
	icon_state = "portal"
	layer = MOB_LAYER+2
	alpha = 0

	New()
		..()
		animate(src, alpha = 255, time = 10)

	Crossed(Player/P)
		if(istype(P,/Player))
			sleep(1)
			P << "INSTANT DEATH"
			P.loc=null