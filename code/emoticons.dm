obj/emoticon
	icon = 'icons/emoticons.dmi'
	pixel_y = 20
	pixel_x = -13
	layer=MOB_LAYER+1
	New(mob/M=null)
		..()
		if(M)
			M.overlays += src
			spawn(10)
			M.overlays -= src
	alert
		icon_state = "alert"
	question
		icon_state = "question"

	typing
		icon_state = "typing"

	angry
		icon_state = "angry"