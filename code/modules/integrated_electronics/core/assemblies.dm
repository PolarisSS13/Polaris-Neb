#define IC_MAX_SIZE_BASE		25
#define IC_COMPLEXITY_BASE		75

/obj/item/electronic_assembly
	name = "electronic assembly"
	desc = "It's a case, for building small electronics with."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_small"
	item_flags = ITEM_FLAG_NO_BLUDGEON
	matter = list()		// To be filled later
	pass_flags = 0
	anchored = FALSE
	obj_flags = OBJ_FLAG_ANCHORABLE
	max_health = 30
	var/list/assembly_components = list()
	var/list/ckeys_allowed_to_scan = list() // Players who built the circuit can scan it as a ghost.
	var/max_components = IC_MAX_SIZE_BASE
	var/max_complexity = IC_COMPLEXITY_BASE
	var/opened = TRUE
	var/obj/item/cell/battery // Internal cell which most circuits need to work.
	var/cell_type = /obj/item/cell
	var/circuit_flags = 0
	var/ext_next_use = 0
	var/weakref/collw
	var/allowed_circuit_action_flags = IC_ACTION_COMBAT | IC_ACTION_LONG_RANGE //which circuit flags are allowed
	var/creator // circuit creator if any
	var/interact_page = 0
	var/components_per_page = 5
	var/detail_color = COLOR_ASSEMBLY_BLACK
	var/list/color_whitelist = list( //This is just for checking that hacked colors aren't in the save data.
		COLOR_ASSEMBLY_BLACK,
		COLOR_GRAY40,
		COLOR_ASSEMBLY_BGRAY,
		COLOR_ASSEMBLY_WHITE,
		COLOR_ASSEMBLY_RED,
		COLOR_ASSEMBLY_ORANGE,
		COLOR_ASSEMBLY_BEIGE,
		COLOR_ASSEMBLY_BROWN,
		COLOR_ASSEMBLY_GOLD,
		COLOR_ASSEMBLY_YELLOW,
		COLOR_ASSEMBLY_GURKHA,
		COLOR_ASSEMBLY_LGREEN,
		COLOR_ASSEMBLY_GREEN,
		COLOR_ASSEMBLY_LBLUE,
		COLOR_ASSEMBLY_BLUE,
		COLOR_ASSEMBLY_PURPLE
		)

/obj/item/electronic_assembly/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(obj_flags & OBJ_FLAG_ANCHORABLE)
		to_chat(user, "<span class='notice'>The anchoring bolts [anchored ? "are" : "can be"] <b>wrenched</b> in place and the maintenance panel [opened ? "can be" : "is"] <b>screwed</b> in place.</span>")
	else
		to_chat(user, "<span class='notice'>The maintenance panel [opened ? "can be" : "is"] <b>screwed</b> in place.</span>")
	if(is_damaged())
		if(get_percent_health() <= 50)
			to_chat(user,"<span class='warning'>It looks pretty beat up.</span>")
		else
			to_chat(user, "<span class='warning'>It's got a few dents in it.</span>")

	if((isobserver(user) && ckeys_allowed_to_scan[user.ckey]) || check_rights(R_ADMIN, 0, user))
		to_chat(user, "You can <a href='byond://?src=\ref[src];ghostscan=1'>scan</a> this circuit.");

/obj/item/electronic_assembly/examined_by(mob/user, distance, infix, suffix)
	. = ..()
	for(var/obj/item/integrated_circuit/component as anything in assembly_components)
		component.external_examine(user)
		if(opened)
			component.internal_examine(user)
	if(opened)
		interact(user)

/obj/item/electronic_assembly/check_health(lastdamage, lastdamtype, lastdamflags, consumed)
	if(!can_take_damage())
		return
	if(current_health < 1)
		visible_message(SPAN_DANGER("\The [src] falls to pieces!"))
		physically_destroyed()
	else if((get_percent_health() < 15) && prob(5))
		visible_message(SPAN_DANGER("\The [src] starts to break apart!"))

/obj/item/electronic_assembly/proc/check_interactivity(mob/user)
	return (!user.incapacitated() && CanUseTopic(user) && user_can_attack_with(user))

/obj/item/electronic_assembly/GetAccess()
	. = list()
	for(var/obj/item/integrated_circuit/output/O in assembly_components)
		var/o_access = O.GetAccess()
		. |= o_access

/obj/item/electronic_assembly/Bump(atom/AM)
	collw = weakref(AM)
	.=..()
	if(istype(AM, /obj/machinery/door/airlock) ||  istype(AM, /obj/machinery/door/window))
		var/obj/machinery/door/D = AM
		if(D.check_access(src))
			D.open()

/obj/item/electronic_assembly/create_matter()
	..()
	LAZYSET(matter, /decl/material/solid/metal/steel, round((max_complexity + max_components) / 4) * SScircuit.cost_multiplier)

/obj/item/electronic_assembly/Initialize()
	. = ..()
	START_PROCESSING(SScircuit, src)

/obj/item/electronic_assembly/Destroy()
	STOP_PROCESSING(SScircuit, src)
	for(var/circ in assembly_components)
		remove_component(circ)
		qdel(circ)
	return ..()

/obj/item/electronic_assembly/Process()
	// First we generate power.
	for(var/obj/item/integrated_circuit/passive/power/P in assembly_components)
		P.make_energy()

	var/power_failure = FALSE
	if(get_health_ratio() < 0.5 && prob(5))
		visible_message(SPAN_WARNING("\The [src] shudders and sparks."))
		power_failure = TRUE
	// Now spend it.
	for(var/obj/item/integrated_circuit/component as anything in assembly_components)
		if(component.power_draw_idle)
			if(power_failure || !draw_power(component.power_draw_idle))
				component.power_fail()

/obj/item/electronic_assembly/receive_mouse_drop(atom/dropping, mob/user, params)
	. = ..()
	if(!. && user == dropping)
		interact(user)
		return TRUE

/obj/item/electronic_assembly/interact(mob/user)
	if(!check_interactivity(user))
		return

	if(opened)
		open_interact(user)
	closed_interact(user)

/obj/item/electronic_assembly/proc/closed_interact(mob/user)
	var/HTML = list()
	HTML += "<html><head><title>[src.name]</title></head><body>"
	HTML += "<br><a href='byond://?src=\ref[src];refresh=1'>\[Refresh\]</a>"
	HTML += "<br><br>"

	var/listed_components = FALSE
	for(var/obj/item/integrated_circuit/circuit in contents)
		var/list/topic_data = circuit.get_topic_data(user)
		if(topic_data)
			listed_components = TRUE
			HTML += "<b>[circuit.displayed_name]: </b>"
			if(topic_data.len != 1)
				HTML += "<br>"
			for(var/entry in topic_data)
				var/href = topic_data[entry]
				if(href)
					HTML += "<a href='byond://?src=\ref[circuit];[href]'>[entry]</a>"
				else
					HTML += entry
				HTML += "<br>"
			HTML += "<br>"
	HTML += "</body></html>"

	if(listed_components)
		show_browser(user, jointext(HTML,null), "window=closed-assembly-\ref[src];size=600x350;border=1;can_resize=1;can_close=1;can_minimize=1")

/obj/item/electronic_assembly/get_assembly_detail_color()
	return detail_color

/obj/item/electronic_assembly/proc/open_interact(mob/user)
	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()
	var/list/HTML = list()

	HTML += "<html><head><title>[name]</title></head><body>"

	HTML += "<a href='byond://?src=\ref[src]'>\[Refresh\]</a>  |  <a href='byond://?src=\ref[src];rename=1'>\[Rename\]</a><br>"
	HTML += "[total_part_size]/[max_components] space taken up in the assembly.<br>"
	HTML += "[total_complexity]/[max_complexity] complexity in the assembly.<br>"
	if(battery)
		HTML += "[round(battery.charge, 0.1)]/[battery.maxcharge] ([round(battery.percent(), 0.1)]%) cell charge. <a href='byond://?src=\ref[src];remove_cell=1'>\[Remove\]</a>"
	else
		HTML += "<span class='danger'>No power cell detected!</span>"

	if(length(assembly_components))
		HTML += "<br><br>"
		HTML += "Components:<br>"

		var/start_index = ((components_per_page * interact_page) + 1)
		for(var/i = start_index to min(length(assembly_components), start_index + (components_per_page - 1)))
			var/obj/item/integrated_circuit/circuit = assembly_components[i]
			HTML += "\[ <a href='byond://?src=\ref[src];component=\ref[circuit];set_slot=1'>[i]</a> \] | "
			HTML += "<a href='byond://?src=\ref[circuit];component=\ref[circuit];rename=1'>\[R\]</a> | "
			if(circuit.removable)
				HTML += "<a href='byond://?src=\ref[src];component=\ref[circuit];remove=1'>\[-\]</a> | "
			else
				HTML += "\[-\] | "
			HTML += "<a href='byond://?src=\ref[circuit];examine=1'>[circuit.displayed_name]</a>"
			HTML += "<br>"

		if(length(assembly_components) > components_per_page)
			HTML += "<br>\["
			for(var/i = 1 to ceil(length(assembly_components)/components_per_page))
				if((i-1) == interact_page)
					HTML += " [i]"
				else
					HTML += " <a href='byond://?src=\ref[src];select_page=[i-1]'>[i]</a>"
			HTML += " \]"

	HTML += "</body></html>"
	show_browser(user, jointext(HTML, null), "window=assembly-\ref[src];size=655x350;border=1;can_resize=1;can_close=1;can_minimize=1")

/obj/item/electronic_assembly/Topic(href, href_list)
	if(href_list["ghostscan"])
		if((isobserver(usr) && ckeys_allowed_to_scan[usr.ckey]) || check_rights(R_ADMIN,0,usr))
			if(assembly_components.len)
				var/saved = "On circuit printers with cloning enabled, you may use the code below to clone the circuit:<br><br><code>[SScircuit.save_electronic_assembly(src)]</code>"
				show_browser(usr, saved, "window=circuit_scan;size=500x600;border=1;can_resize=1;can_close=1;can_minimize=1")
			else
				to_chat(usr, "<span class='warning'>The circuit is empty!</span>")
		return 0

	if(isobserver(usr))
		return

	if(!check_interactivity(usr))
		return 0

	if(href_list["select_page"])
		interact_page = text2num(href_list["select_page"])

	if(href_list["rename"])
		rename(usr)

	if(href_list["remove_cell"])
		if(!battery)
			to_chat(usr, "<span class='warning'>There's no power cell to remove from \the [src].</span>")
		else
			battery.dropInto(loc)
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
			to_chat(usr, "<span class='notice'>You pull \the [battery] out of \the [src]'s power supplier.</span>")
			battery = null

	if(href_list["component"])
		var/obj/item/integrated_circuit/component = locate(href_list["component"]) in assembly_components
		if(component)
			// Builtin components are not supposed to be removed or rearranged
			if(!component.removable)
				return 0

			add_allowed_scanner(usr.ckey)

			var/current_pos = assembly_components.Find(component)

			if(href_list["remove"])
				try_remove_component(component, usr)

			else
				// Adjust the position
				if(href_list["set_slot"])
					var/selected_slot = input("Select a new slot", "Select slot", current_pos) as null|num
					if(!check_interactivity(usr))
						return 0
					if(selected_slot < 1 || selected_slot > length(assembly_components))
						return 0

					assembly_components.Remove(component)
					assembly_components.Insert(selected_slot, component)


	interact(usr) // To refresh the UI.

/obj/item/electronic_assembly/proc/rename()
	var/mob/M = usr
	if(!check_interactivity(M))
		return
	var/input = input("What do you want to name this?", "Rename", src.name) as null|text
	input = sanitize_name(input,allow_numbers = 1)
	if(!check_interactivity(M))
		return
	if(!QDELETED(src) && input)
		to_chat(M, "<span class='notice'>The machine now has a label reading '[input]'.</span>")
		name = input

/obj/item/electronic_assembly/proc/add_allowed_scanner(ckey)
	ckeys_allowed_to_scan[ckey] = TRUE

/obj/item/electronic_assembly/proc/can_move()
	return FALSE

/obj/item/electronic_assembly/on_update_icon()
	. = ..()
	if(opened)
		icon_state = initial(icon_state) + "-open"
	else
		icon_state = initial(icon_state)
	if(detail_color == COLOR_ASSEMBLY_BLACK) //Black colored overlay looks almost but not exactly like the base sprite, so just cut the overlay and avoid it looking kinda off.
		return
	add_overlay(overlay_image('icons/obj/assemblies/electronic_setups.dmi', "[icon_state]-color", detail_color))

//This only happens when this EA is loaded via the printer
/obj/item/electronic_assembly/proc/post_load()
	for(var/obj/item/integrated_circuit/component as anything in assembly_components)
		component.on_data_written()

/obj/item/electronic_assembly/proc/return_total_complexity()
	. = 0
	var/obj/item/integrated_circuit/part
	for(var/p in assembly_components)
		part = p
		. += part.complexity

/obj/item/electronic_assembly/proc/return_total_size()
	. = 0
	var/obj/item/integrated_circuit/part
	for(var/p in assembly_components)
		part = p
		. += part.size

// Returns true if the circuit made it inside.
/obj/item/electronic_assembly/proc/try_add_component(obj/item/integrated_circuit/component, mob/user)
	if(!opened)
		to_chat(user, "<span class='warning'>\The [src]'s hatch is closed, you can't put anything inside.</span>")
		return FALSE

	if(component.w_class > w_class)
		to_chat(user, "<span class='warning'>\The [component] is way too big to fit into \the [src].</span>")
		return FALSE

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()

	if((total_part_size + component.size) > max_components)
		to_chat(user, "<span class='warning'>You can't seem to add the '[component]', as there's insufficient space.</span>")
		return FALSE
	if((total_complexity + component.complexity) > max_complexity)
		to_chat(user, "<span class='warning'>You can't seem to add the '[component]', since this setup's too complicated for the case.</span>")
		return FALSE
	if((allowed_circuit_action_flags & component.action_flags) != component.action_flags)
		to_chat(user, "<span class='warning'>You can't seem to add the '[component]', since the case doesn't support the circuit type.</span>")
		return FALSE

	if(!user.try_unequip(component,src))
		return FALSE

	to_chat(user, "<span class='notice'>You slide [component] inside [src].</span>")
	playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
	add_allowed_scanner(user.ckey)

	add_component(component)
	return TRUE


// Actually puts the circuit inside, doesn't perform any checks.
/obj/item/electronic_assembly/proc/add_component(obj/item/integrated_circuit/component)
	component.forceMove(get_object())
	component.assembly = src
	assembly_components |= component


/obj/item/electronic_assembly/proc/try_remove_component(obj/item/integrated_circuit/component, mob/user, silent)
	if(!opened)
		if(!silent)
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't fiddle with the internal components.</span>")
		return FALSE

	if(!component.removable)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is permanently attached to the case.</span>")
		return FALSE

	remove_component(component)
	if(!silent)
		to_chat(user, "<span class='notice'>You pop \the [component] out of the case, and slide it out.</span>")
		playsound(src, 'sound/items/crowbar.ogg', 50, 1)
		user.put_in_hands(component)
	add_allowed_scanner(user.ckey)

	// Make sure we're not on an invalid page
	interact_page = clamp(interact_page, 0, ceil(length(assembly_components)/components_per_page)-1)

	return TRUE

// Actually removes the component, doesn't perform any checks.
/obj/item/electronic_assembly/proc/remove_component(obj/item/integrated_circuit/component)
	component.disconnect_all()
	component.dropInto(loc)
	component.assembly = null
	assembly_components.Remove(component)


/obj/item/electronic_assembly/afterattack(atom/target, mob/user, proximity)
	. = ..()
	for(var/obj/item/integrated_circuit/input/S in assembly_components)
		if(S.sense(target,user,proximity))
			if(proximity)
				visible_message("<span class='notice'>\The [user] waves \the [src] around \the [target].</span>")
			else
				visible_message("<span class='notice'>\The [user] points \the [src] towards \the [target].</span>")


/obj/item/electronic_assembly/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, /obj/item/integrated_circuit))
		if(!user.can_unequip_item(used_item))
			return FALSE
		if(try_add_component(used_item, user))
			return TRUE
		else
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(used_item, user, user.get_intent())
			return ..()
	else if(IS_MULTITOOL(used_item) || istype(used_item, /obj/item/integrated_electronics/wirer) || istype(used_item, /obj/item/integrated_electronics/debugger))
		if(opened)
			interact(user)
			return TRUE
		else
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't fiddle with the internal components.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(used_item, user, user.get_intent())
			return ..()
	else if(istype(used_item, /obj/item/cell))
		if(!opened)
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't access \the [src]'s power supplier.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(used_item, user, user.get_intent())
			return ..()
		if(battery)
			to_chat(user, "<span class='warning'>[src] already has \a [battery] installed. Remove it first if you want to replace it.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(used_item, user, user.get_intent())
			return ..()
		var/obj/item/cell/cell = used_item
		if(user.try_unequip(used_item,loc))
			user.drop_from_inventory(used_item, loc)
			cell.forceMove(src)
			battery = cell
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You slot \the [cell] inside \the [src]'s power supplier.</span>")
			return TRUE
		return FALSE
	else if(istype(used_item, /obj/item/integrated_electronics/detailer))
		var/obj/item/integrated_electronics/detailer/D = used_item
		detail_color = D.detail_color
		update_icon()
	else if(IS_SCREWDRIVER(used_item))
		var/hatch_locked = FALSE
		for(var/obj/item/integrated_circuit/manipulation/hatchlock/H in assembly_components)
			// If there's more than one hatch lock, only one needs to be enabled for the assembly to be locked
			if(H.lock_enabled)
				hatch_locked = TRUE
				break

		if(hatch_locked)
			to_chat(user, "<span class='notice'>The screws are covered by a locking mechanism!</span>")
			return FALSE

		playsound(src, 'sound/items/Screwdriver.ogg', 25)
		opened = !opened
		to_chat(user, "<span class='notice'>You [opened ? "open" : "close"] the maintenance hatch of [src].</span>")
		update_icon()
		return TRUE

	else if(IS_COIL(used_item))
		var/obj/item/stack/cable_coil/C = used_item
		if(is_damaged() && do_after(user, 10, src) && C.use(1))
			user.visible_message("\The [user] patches up \the [src].")
			current_health = min(get_max_health(), current_health + 5)
		return TRUE

	else if(!user.check_intent(I_FLAG_HARM))
		for(var/obj/item/integrated_circuit/input/S in assembly_components)
			S.attackby_react(used_item, user, user.get_intent())
		return TRUE

	return ..() //Handle weapon attacks and etc

/obj/item/electronic_assembly/attack_self(mob/user)
	interact(user)

/obj/item/electronic_assembly/bullet_act(var/obj/item/projectile/P)
	take_damage(P.damage, P.atom_damage_type)

/obj/item/electronic_assembly/emp_act(severity)
	. = ..()
	for(var/atom/movable/thing as anything in get_contained_external_atoms())
		thing.emp_act(severity)

// Returns true if power was successfully drawn.
/obj/item/electronic_assembly/proc/draw_power(amount)
	if(battery && battery.use(amount * CELLRATE))
		return TRUE
	return FALSE

// Ditto for giving.
/obj/item/electronic_assembly/proc/give_power(amount)
	if(battery && battery.give(amount * CELLRATE))
		return TRUE
	return FALSE


// Returns the object that is supposed to be used in attack messages, location checks, etc.
// Override in children for special behavior.
/obj/item/electronic_assembly/proc/get_object()
	return src

/obj/item/electronic_assembly/attack_hand(mob/user)
	if(!anchored)
		return ..()
	attack_self(user)
	return TRUE

/obj/item/electronic_assembly/default //The /default electronic_assemblys are to allow the introduction of the new naming scheme without breaking old saves.
  name = "type-a electronic assembly"

/obj/item/electronic_assembly/calc
	name = "type-b electronic assembly"
	icon_state = "setup_small_calc"
	desc = "It's a case, for building small electronics with. This one resembles a pocket calculator."

/obj/item/electronic_assembly/clam
	name = "type-c electronic assembly"
	icon_state = "setup_small_clam"
	desc = "It's a case, for building small electronics with. This one has a clamshell design."

/obj/item/electronic_assembly/simple
	name = "type-d electronic assembly"
	icon_state = "setup_small_simple"
	desc = "It's a case, for building small electronics with. This one has a simple design."

/obj/item/electronic_assembly/hook
	name = "type-e electronic assembly"
	icon_state = "setup_small_hook"
	desc = "It's a case, for building small electronics with. This one looks like it has a belt clip."
	slot_flags = SLOT_LOWER_BODY

/obj/item/electronic_assembly/pda
	name = "type-f electronic assembly"
	icon_state = "setup_small_pda"
	desc = "It's a case, for building small electronics with. This one resembles a PDA."
	slot_flags = SLOT_LOWER_BODY | SLOT_ID

/obj/item/electronic_assembly/augment
	name = "augment electronic assembly"
	icon_state = "setup_augment"
	desc = "It's a case, for building small electronics with. This one is designed to go inside a cybernetic augment."
	circuit_flags = IC_FLAG_CAN_FIRE

/obj/item/electronic_assembly/medium
	name = "electronic mechanism"
	icon_state = "setup_medium"
	desc = "It's a case, for building medium-sized electronics with."
	w_class = ITEM_SIZE_NORMAL
	max_components = IC_MAX_SIZE_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2
	max_health = 20

/obj/item/electronic_assembly/medium/default
	name = "type-a electronic mechanism"

/obj/item/electronic_assembly/medium/box
	name = "type-b electronic mechanism"
	icon_state = "setup_medium_box"
	desc = "It's a case, for building medium-sized electronics with. This one has a boxy design."

/obj/item/electronic_assembly/medium/clam
	name = "type-c electronic mechanism"
	icon_state = "setup_medium_clam"
	desc = "It's a case, for building medium-sized electronics with. This one has a clamshell design."

/obj/item/electronic_assembly/medium/medical
	name = "type-d electronic mechanism"
	icon_state = "setup_medium_med"
	desc = "It's a case, for building medium-sized electronics with. This one resembles some type of medical apparatus."

/obj/item/electronic_assembly/medium/gun
	name = "type-e electronic mechanism"
	icon_state = "setup_medium_gun"
	item_state = "circuitgun"
	desc = "It's a case, for building medium-sized electronics with. This one resembles a gun, or some type of tool, if you're feeling optimistic. It can fire guns and throw items while the user is holding it."
	circuit_flags = IC_FLAG_CAN_FIRE
	obj_flags = OBJ_FLAG_ANCHORABLE

/obj/item/electronic_assembly/medium/radio
	name = "type-f electronic mechanism"
	icon_state = "setup_medium_radio"
	desc = "It's a case, for building medium-sized electronics with. This one resembles an old radio."

/obj/item/electronic_assembly/large
	name = "electronic machine"
	icon_state = "setup_large"
	desc = "It's a case, for building large electronics with."
	w_class = ITEM_SIZE_LARGE
	max_components = IC_MAX_SIZE_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4
	max_health = 30

/obj/item/electronic_assembly/large/default
	name = "type-a electronic machine"

/obj/item/electronic_assembly/large/scope
	name = "type-b electronic machine"
	icon_state = "setup_large_scope"
	desc = "It's a case, for building large electronics with. This one resembles an oscilloscope."

/obj/item/electronic_assembly/large/terminal
	name = "type-c electronic machine"
	icon_state = "setup_large_terminal"
	desc = "It's a case, for building large electronics with. This one resembles a computer terminal."

/obj/item/electronic_assembly/large/arm
	name = "type-d electronic machine"
	icon_state = "setup_large_arm"
	desc = "It's a case, for building large electronics with. This one resembles a robotic arm."

/obj/item/electronic_assembly/large/tall
	name = "type-e electronic machine"
	icon_state = "setup_large_tall"
	desc = "It's a case, for building large electronics with. This one has a tall design."

/obj/item/electronic_assembly/large/industrial
	name = "type-f electronic machine"
	icon_state = "setup_large_industrial"
	desc = "It's a case, for building large electronics with. This one resembles some kind of industrial machinery."

/obj/item/electronic_assembly/drone
	name = "electronic drone"
	icon_state = "setup_drone"
	desc = "It's a case, for building mobile electronics with."
	w_class = ITEM_SIZE_LARGE
	max_components = IC_MAX_SIZE_BASE * 3
	max_complexity = IC_COMPLEXITY_BASE * 3
	allowed_circuit_action_flags = IC_ACTION_MOVEMENT | IC_ACTION_COMBAT | IC_ACTION_LONG_RANGE
	circuit_flags = 0
	obj_flags = 0 //Not anchorable
	max_health = 50

/obj/item/electronic_assembly/drone/can_move()
	return TRUE

/obj/item/electronic_assembly/drone/default
	name = "type-a electronic drone"

/obj/item/electronic_assembly/drone/arms
	name = "type-b electronic drone"
	icon_state = "setup_drone_arms"
	desc = "It's a case, for building mobile electronics with. This one is armed and dangerous."

/obj/item/electronic_assembly/drone/secbot
	name = "type-c electronic drone"
	icon_state = "setup_drone_secbot"
	desc = "It's a case, for building mobile electronics with. This one resembles a Securitron."

/obj/item/electronic_assembly/drone/medbot
	name = "type-d electronic drone"
	icon_state = "setup_drone_medbot"
	desc = "It's a case, for building mobile electronics with. This one resembles a Medibot."

/obj/item/electronic_assembly/drone/genbot
	name = "type-e electronic drone"
	icon_state = "setup_drone_genbot"
	desc = "It's a case, for building mobile electronics with. This one has a generic bot design."

/obj/item/electronic_assembly/drone/android
	name = "type-f electronic drone"
	icon_state = "setup_drone_android"
	desc = "It's a case, for building mobile electronics with. This one has a hominoid design."

/obj/item/electronic_assembly/wallmount
	name = "wall-mounted electronic assembly"
	icon_state = "setup_wallmount_medium"
	desc = "It's a case, for building medium-sized electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = ITEM_SIZE_NORMAL
	max_components = IC_MAX_SIZE_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2
	max_health = 10

/obj/item/electronic_assembly/wallmount/afterattack(var/atom/a, var/mob/user, var/proximity)
	if(proximity && istype(a ,/turf) && a.density)
		mount_assembly(a,user)

/obj/item/electronic_assembly/wallmount/heavy
	name = "heavy wall-mounted electronic assembly"
	icon_state = "setup_wallmount_large"
	desc = "It's a case, for building large electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = ITEM_SIZE_LARGE
	max_components = IC_MAX_SIZE_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4

/obj/item/electronic_assembly/wallmount/light
	name = "light wall-mounted electronic assembly"
	icon_state = "setup_wallmount_small"
	desc = "It's a case, for building small electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = ITEM_SIZE_SMALL
	max_components = IC_MAX_SIZE_BASE
	max_complexity = IC_COMPLEXITY_BASE

/obj/item/electronic_assembly/on_picked_up()
	transform = null //Reset the matrix.

/obj/item/electronic_assembly/wallmount/proc/mount_assembly(turf/on_wall, mob/user) //Yeah, this is admittedly just an abridged and kitbashed version of the wallframe attach procs.
	var/ndir = get_dir(on_wall, user)
	if(!(ndir in global.cardinal))
		return
	var/turf/T = get_turf(user)
	if(T.density)
		to_chat(user, "<span class='warning'>You cannot place [src] on this spot!</span>")
		return
	if(gotwallitem(T, ndir))
		to_chat(user, "<span class='warning'>There's already an item on this wall!</span>")
		return
	playsound(src.loc, 'sound/machines/click.ogg', 75, 1)
	user.visible_message("[user.name] attaches [src] to the wall.",
		"<span class='notice'>You attach [src] to the wall.</span>",
		"<span class='italics'>You hear clicking.</span>")
	if(user.try_unequip(src,T))
		var/matrix/M = matrix()
		switch(ndir)
			if(NORTH)
				default_pixel_y = -32
				default_pixel_x = 0
				M.Turn(180)
			if(SOUTH)
				default_pixel_y = 21
				default_pixel_x = 0
			if(EAST)
				default_pixel_x = -27
				default_pixel_y = 0
				M.Turn(270)
			if(WEST)
				default_pixel_x = 27
				default_pixel_y = 0
				M.Turn(90)
		reset_offsets(0)
		transform = M

#undef IC_MAX_SIZE_BASE
#undef IC_COMPLEXITY_BASE
