/obj/structure/artilleryplaceholder
	name = "artillery"
	desc = "The ship's old superluminal artillery cannon. Looks inoperative."
	icon = 'icons/obj/machines/artillery.dmi'
	anchored = TRUE
	density = TRUE

/obj/structure/artilleryplaceholder/decorative
	density = FALSE

/obj/machinery/artillerycontrol
	name = "superluminal artillery control"
	icon_state = "control_boxp1"
	icon = 'icons/obj/machines/particle_accelerator2.dmi'
	density = TRUE
	anchored = TRUE
	var/tmp/time_to_reload = 360 SECONDS // originally this was 180 ticks at 1 tick per 2 seconds
	var/reload_cooldown = 0 // The world.time value after which we will be able to fire.

/obj/machinery/artillerycontrol/interface_interact(mob/user)
	interact(user)
	return TRUE

/obj/machinery/artillerycontrol/interact(mob/user)
	user.set_machine(src)
	var/dat = list("<B>Superluminal Artillery Control:</B><BR>")
	dat += "Locked on<BR>"
	dat += "<B>Charge progress: [round(100 - ((reload_cooldown - world.time) / time_to_reload))]%</B><BR>"
	dat += "<A href='byond://?src=\ref[src];fire=1'>Open Fire</A><BR>"
	dat += "Deployment of weapon authorized by <br>[global.using_map.company_name] Naval Command<br><br>Remember, friendly fire is grounds for termination of your contract and life.<HR>"
	show_browser(user, JOINTEXT(dat), "window=superlumcontrol")
	onclose(user, "superlumcontrol")

/obj/machinery/artillerycontrol/OnTopic(mob/user, href_list)
	if((. = ..()))
		return

	var/area/thearea = input("Area to jump bombard", "Open Fire") as null|anything in teleportlocs
	thearea = thearea ? teleportlocs[thearea] : null
	if (!thearea)
		return
	if (world.time < reload_cooldown)
		return
	command_announcement.Announce("Wormhole artillery fire detected. Brace for impact.")
	log_and_message_admins("has launched an artillery strike.", user, get_turf(src))
	var/list/turf/candidates = list()
	// this is slow (in world loop) but we don't have a better way unless we pre-register a list of areas -> z-levels
	// and this code isn't hot code at all
	for(var/turf/tile in thearea)
		candidates += tile
	var/turf/target_loc = pick(candidates)
	explosion(target_loc, 2, 5, 11)
	reload_cooldown = world.time + time_to_reload
