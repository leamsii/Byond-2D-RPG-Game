Alpha_Text
	parent_type = /obj
	icon = 'icons/Alphabet.dmi'
	New(client/c)
		c.screen += src


proc/Create_Text(mob/M, msg, x, y)
	// Clear out any other text on screen
	for(var/Alpha_Text/T in M.client.screen)
		del T

	for(var/i = 1; i <= length(msg); i++)
		var/Alpha_Text/T = new(M.client)
		T.icon_state = msg[i]
		T.screen_loc = "[x]:[i * 7], [y]"