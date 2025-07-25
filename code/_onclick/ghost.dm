/client/var/inquisitive_ghost = 1
/mob/observer/ghost/verb/toggle_inquisition() // warning: unexpected inquisition
	set name = "Toggle Inquisitiveness"
	set desc = "Sets whether your ghost examines everything on click by default"
	set category = "Ghost"
	if(!client) return
	client.inquisitive_ghost = !client.inquisitive_ghost
	if(client.inquisitive_ghost)
		to_chat(src, "<span class='notice'>You will now examine everything you click on.</span>")
	else
		to_chat(src, "<span class='notice'>You will no longer examine things you click on.</span>")

/mob/observer/ghost/DblClickOn(var/atom/A, var/params)
	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, exosuit, etc)
			return

	// Things you might plausibly want to follow
	if(istype(A,/atom/movable))
		ManualFollow(A)
	// Otherwise jump
	else
		stop_following()
		forceMove(get_turf(A))

/mob/observer/ghost/ClickOn(var/atom/A, var/params)
	if(!canClick()) return
	setClickCooldown(DEFAULT_QUICK_COOLDOWN)

	// You are responsible for checking ghost_interaction when you override this function
	// Not all of them require checking, see below
	var/list/modifiers = params2list(params)
	if(modifiers["alt"])
		AltClickOn(A)
		return
	if(modifiers["shift"])
		examine_verb(A)
		return
	A.attack_ghost(src)

// Oh by the way this didn't work with old click code which is why clicking shit didn't spam you
/atom/proc/attack_ghost(mob/observer/ghost/user)
	if(!istype(user))
		return
	if(user.client && user.client.inquisitive_ghost)
		user.examine_verb(src)
		return
	if(user.client?.holder || user.antagHUD)
		storage?.show_to(user)
	return

// ---------------------------------------
// And here are some good things for free:
// Now you can click through portals, wormholes, gateways, and teleporters while observing. -Sayu

/obj/machinery/teleport/hub/attack_ghost(mob/user)
	if(com?.locked)
		user.forceMove(get_turf(com.locked))

/obj/effect/portal/attack_ghost(mob/user)
	if(target)
		user.forceMove(get_turf(target))
