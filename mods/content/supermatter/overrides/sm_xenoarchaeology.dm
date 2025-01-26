/datum/artifact_find/New()
	var/static/supermatter_injected = FALSE
	if(!supermatter_injected)
		potential_finds[/obj/machinery/power/supermatter] = 5
		potential_finds[/obj/machinery/power/supermatter/shard] = 25
		supermatter_injected = TRUE
	..()
