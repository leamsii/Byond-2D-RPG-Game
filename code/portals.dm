Portal
	parent_type = /obj
	icon = 'icons/portal.dmi'
	icon_state = "portal"
	layer = MOB_LAYER+2
	alpha = 0

	New()
		..()
		animate(src, alpha = 255, time = 10)

	Cross(Player/P)
		if(istype(P,/Player))
			P.loc=locate(10,12,2)
