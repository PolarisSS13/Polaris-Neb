var/global/datum/cinematic/cinematic = new
/datum/cinematic
	//station_explosion used to be a variable for every mob's hud. Which was a waste!
	//Now we have a general cinematic centrally held within the gameticker....far more efficient!
	var/obj/screen/cinematic/cinematic_screen = null

//Plus it provides an easy way to make cinematics for other events. Just use this as a template :)
/datum/cinematic/proc/station_explosion_cinematic(var/station_missed=0, var/decl/game_mode/override)
	set waitfor = FALSE

	if(cinematic_screen)
		return	//already a cinematic in progress!

	if(!override)
		override = SSticker.mode
	if(!override)
		override = GET_DECL(/decl/game_mode/extended)
	if(!override)
		return

	//initialise our cinematic screen object
	cinematic_screen = new

	//Let's not discuss how this worked previously.
	var/list/viewers = list()
	for(var/mob/living/M in global.living_mob_list_)
		if(M.client)
			M.client.screen += cinematic_screen //show every client the cinematic
			viewers[M.client] = GET_STATUS(M, STAT_STUN)
			M.set_status_condition(STAT_STUN, 8000)

	override.nuke_act(cinematic_screen, station_missed) //cinematic happens here, as does mob death.
	//If it's actually the end of the round, wait for it to end.
	//Otherwise if it's a verb it will continue on afterwards.
	sleep(30 SECONDS)

	for(var/client/C in viewers)
		if(C.mob)
			C.mob.set_status_condition(STAT_STUN, viewers[C])
		C.screen -= cinematic_screen
	QDEL_NULL(cinematic_screen)