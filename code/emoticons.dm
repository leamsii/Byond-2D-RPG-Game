Emoticon
	parent_type = /obj
	icon = 'icons/emoticons.dmi'
	layer=MOB_LAYER+99

	New(mob/M=null, x=0, y=0)
		..()
		pixel_x = x
		pixel_y = y
		if(M)
			M.overlays += src
			spawn(10)
			M.overlays -= src
	Alert
		icon_state = "alert"
	Question
		icon_state = "question"
	Typing
		icon_state = "typing"
	Angry
		icon_state = "angry"