#define GET_ZAS_IMAGE(T, IS) image(loc = T, icon = 'icons/misc/debug_group.dmi', icon_state = IS, layer = ABOVE_TILE_LAYER)

//- Are all the floors with or without air, as they should be? (regular or airless)
//- Does the area have an APC?
//- Does the area have an Air Alarm?
//- Does the area have a Request Console?
//- Does the area have lights?
//- Does the area have a light switch?
//- Does the area have enough intercoms?
//- Does the area have enough security cameras? (Use the 'Camera Range Display' verb under Debug)
//- Is the area connected to the scrubbers air loop?
//- Is the area connected to the vent air loop? (vent pumps)
//- Is everything wired properly?
//- Does the area have a fire alarm and firedoors?
//- Do all pod doors work properly?
//- Are accesses set properly on doors, pod buttons, etc.
//- Are all items placed properly? (not below vents, scrubbers, tables)
//- Does the disposal system work properly from all the disposal units in this room and all the units, the pipes of which pass through this room?
//- Check for any misplaced or stacked piece of pipe (air and disposal)
//- Check for any misplaced or stacked piece of wire
//- Identify how hard it is to break into the area and where the weak points are
//- Check if the area has too much empty space. If so, make it smaller and replace the rest with maintenance tunnels.

var/global/camera_range_display_status = 0
var/global/intercom_range_display_status = 0

var/global/list/debug_camera_range_markers = list()
/obj/effect/debugging/camera_range
	icon = 'icons/480x480.dmi'
	icon_state = "25percent"

/obj/effect/debugging/camera_range/Initialize()
	. = ..()
	default_pixel_x = -224
	default_pixel_y = -224
	reset_offsets(0)
	global.debug_camera_range_markers += src

/obj/effect/debugging/camera_range/Destroy()
	global.debug_camera_range_markers -= src
	return ..()

var/global/list/mapping_debugging_markers = list()
/obj/effect/debugging/marker
	icon = 'icons/turf/areas.dmi'
	icon_state = "yellow"

/obj/effect/debugging/marker/Initialize(mapload)
	. = ..()
	global.mapping_debugging_markers += src

/obj/effect/debugging/marker/Destroy()
	global.mapping_debugging_markers -= src
	return ..()

/obj/effect/debugging/marker/Move()
	return 0

/client/proc/do_not_use_these()
	set category = "Mapping"
	set name = "-None of these are for ingame use!!"

/client/proc/camera_view()
	set category = "Mapping"
	set name = "Camera Range Display"

	if(camera_range_display_status)
		camera_range_display_status = 0
	else
		camera_range_display_status = 1



	for(var/obj/effect/debugging/camera_range/C as anything in debug_camera_range_markers)
		qdel(C)

	if(camera_range_display_status)
		for(var/obj/machinery/camera/C in cameranet.cameras)
			new/obj/effect/debugging/camera_range(C.loc)
	SSstatistics.add_field_details("admin_verb","mCRD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/client/proc/sec_camera_report()
	set category = "Mapping"
	set name = "Camera Report"

	var/list/obj/machinery/camera/CL = list()

	for(var/obj/machinery/camera/C in cameranet.cameras)
		CL += C

	var/output = {"<B>CAMERA ANNOMALITIES REPORT</B><HR>
<B>The following annomalities have been detected. The ones in red need immediate attention: Some of those in black may be intentional.</B><BR><ul>"}

	for(var/obj/machinery/camera/C1 in CL)
		var/area/C1_area = get_area(C1)
		for(var/obj/machinery/camera/C2 in CL)
			var/area/C2_area = get_area(C2)
			if(C1 != C2)
				if(C1.c_tag == C2.c_tag)
					output += "<li><font color='red'>c_tag match for sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1_area.proper_name]) and \[[C2.x], [C2.y], [C2.z]\] ([C2_area.proper_name]) - c_tag is [C1.c_tag]</font></li>"
				if(C1.loc == C2.loc && C1.dir == C2.dir && C1.pixel_x == C2.pixel_x && C1.pixel_y == C2.pixel_y)
					output += "<li><font color='red'>FULLY overlapping sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1_area.proper_name]) Channels: [C1.preset_channels] and [C2.preset_channels]</font></li>"
				if(C1.loc == C2.loc)
					output += "<li>overlapping sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1_area.proper_name]) Channels: [C1.preset_channels] and [C2.preset_channels]</font></li>"
		var/turf/T = get_step(C1,turn(C1.dir,180))
		if(!T || !isturf(T) || !T.density )
			if(!(locate(/obj/structure/grille,T)))
				var/window_check = 0
				for(var/obj/structure/window/window in T)
					if (window.dir == turn(C1.dir,180) || (window.dir in list(NORTHEAST,SOUTHEAST,SOUTHWEST,NORTHWEST)) )
						window_check = 1
						break
				if(!window_check)
					output += "<li><font color='red'>Camera not connected to wall at \[[C1.x], [C1.y], [C1.z]\] ([C1_area.proper_name]) Channels: [C1.preset_channels]</color></li>"

	output += "</ul>"
	show_browser(usr, output, "window=airreport;size=1000x500")
	SSstatistics.add_field_details("admin_verb","mCRP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/intercom_view()
	set category = "Mapping"
	set name = "Intercom Range Display"

	if(intercom_range_display_status)
		intercom_range_display_status = 0
	else
		intercom_range_display_status = 1

	for(var/obj/effect/debugging/marker/M in global.mapping_debugging_markers)
		qdel(M)

	if(intercom_range_display_status)
		for(var/obj/item/radio/intercom/I in SSmachines.machinery)
			for(var/turf/T in orange(7,I))
				var/obj/effect/debugging/marker/F = new/obj/effect/debugging/marker(T)
				if (!(F in view(7,I.loc)))
					qdel(F)

	SSstatistics.add_field_details("admin_verb","mIRD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

var/global/list/debug_verbs = list (
		/client/proc/do_not_use_these,
		/client/proc/camera_view,
		/client/proc/sec_camera_report,
		/client/proc/intercom_view,
		/client/proc/Cell,
		/client/proc/powerdebug,
		/client/proc/count_objects_on_z_level,
		/client/proc/count_objects_all,
		/client/proc/cmd_assume_direct_control,
		/client/proc/startSinglo,
		/client/proc/ticklag,
		/client/proc/cmd_admin_grantfullaccess,
		/client/proc/cmd_admin_areatest,
		/client/proc/cmd_admin_rejuvenate,
		/datum/admins/proc/show_special_roles,
		/client/proc/print_jobban_old,
		/client/proc/print_jobban_old_filter,
		/client/proc/forceEvent,
		/client/proc/Zone_Info,
		/client/proc/Test_ZAS_Connection,
		/client/proc/rebootAirMaster,
		/client/proc/hide_debug_verbs,
		/client/proc/testZAScolors,
		/client/proc/testZAScolors_remove,
		/datum/admins/proc/setup_fusion,
		/client/proc/atmos_toggle_debug,
		/client/proc/spawn_tanktransferbomb,
		/client/proc/find_leaky_pipes,
		/client/proc/analyze_openturf,
		/client/proc/show_cargo_prices
	)


/client/proc/enable_debug_verbs()
	set category = "Debug"
	set name = "Debug verbs"

	if(!check_rights(R_DEBUG)) return

	verbs += debug_verbs

	SSstatistics.add_field_details("admin_verb","mDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/hide_debug_verbs()
	set category = "Debug"
	set name = "Hide Debug verbs"

	if(!check_rights(R_DEBUG)) return

	verbs -= debug_verbs

	SSstatistics.add_field_details("admin_verb","hDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/var/list/testZAScolors_turfs = list()
/client/var/list/testZAScolors_zones = list()
/client/var/usedZAScolors = 0

/client/proc/recurse_zone(var/zone/Z, var/recurse_level =1)
	testZAScolors_zones += Z
	if(recurse_level > 10)
		return

	for(var/turf/T in Z.contents)
		images += GET_ZAS_IMAGE(T, "yellow")
		testZAScolors_turfs += T
	for(var/connection_edge/zone/edge in Z.edges)
		var/zone/connected = edge.get_connected_zone(Z)
		if(connected in testZAScolors_zones)
			continue
		recurse_zone(connected,recurse_level+1)


/client/proc/testZAScolors()
	set category = "ZAS"
	set name = "Check ZAS connections"

	if(!check_rights(R_DEBUG)) return
	testZAScolors_remove()

	var/turf/location = get_turf(usr)
	if(!location?.zone)
		to_chat(src, SPAN_WARNING("The turf you are standing on does not have a zone."))
		return

	if(!usedZAScolors)
		to_chat(src, "ZAS Test Colors")
		to_chat(src, "Green = Zone you are standing in")
		to_chat(src, "Blue = Connected zone to the zone you are standing in")
		to_chat(src, "Yellow = A zone that is connected but not one adjacent to your connected zone")
		to_chat(src, "Red = Not connected")
		usedZAScolors = 1

	testZAScolors_zones += location.zone
	for(var/turf/T in location.zone.contents)
		images += GET_ZAS_IMAGE(T, "green")
		testZAScolors_turfs += T
	for(var/connection_edge/zone/edge in location.zone.edges)
		var/zone/Z = edge.get_connected_zone(location.zone)
		testZAScolors_zones += Z
		for(var/turf/T in Z.contents)
			images += GET_ZAS_IMAGE(T, "blue")
			testZAScolors_turfs += T
		for(var/connection_edge/zone/z_edge in Z.edges)
			var/zone/connected = z_edge.get_connected_zone(Z)
			if(connected in testZAScolors_zones)
				continue
			recurse_zone(connected,1)

	for(var/turf/T in range(25,location))
		if(!istype(T))
			continue
		if(T in testZAScolors_turfs)
			continue
		images += GET_ZAS_IMAGE(T, "red")
		testZAScolors_turfs += T

/client/proc/testZAScolors_remove()
	set category = "ZAS"
	set name = "Remove ZAS connection colors"

	testZAScolors_turfs.Cut()
	testZAScolors_zones.Cut()

	for(var/image/i in images)
		if(i.icon == 'icons/misc/debug_group.dmi')
			images.Remove(i)

/client/proc/rebootAirMaster()
	set category = "ZAS"
	set name = "Reboot ZAS"

	if(alert("This will destroy and remake all zone geometry on the whole map.","Reboot ZAS","Reboot ZAS","Nevermind") == "Reboot ZAS")
		SSair.reboot()


/client/proc/count_objects_on_z_level()
	set category = "Mapping"
	set name = "Count Objects On Level"
	var/level = input("Which z-level?","Level?") as text
	if(!level) return
	var/num_level = text2num(level)
	if(!num_level) return
	if(!isnum(num_level)) return

	var/type_text = input("Which type path?","Path?") as text
	if(!type_text) return
	var/type_path = text2path(type_text)
	if(!type_path) return

	var/count = 1

	var/list/atom/atom_list = list()

	for(var/atom/A in world)
		if(istype(A,type_path))
			var/atom/B = A
			while(!(isturf(B.loc)))
				if(B && B.loc)
					B = B.loc
				else
					break
			if(B)
				if(B.z == num_level)
					count++
					atom_list += A
	/*
	var/atom/temp_atom
	for(var/i = 0; i <= (atom_list.len/10); i++)
		var/line = ""
		for(var/j = 1; j <= 10; j++)
			if(i*10+j <= atom_list.len)
				temp_atom = atom_list[i*10+j]
				line += " no.[i+10+j]@\[[temp_atom.x], [temp_atom.y], [temp_atom.z]\]; "
		log_debug(line) */

	log_debug("There are [count] objects of type [type_path] on z-level [num_level]")
	SSstatistics.add_field_details("admin_verb","mOBJZ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_all()
	set category = "Mapping"
	set name = "Count Objects All"

	var/type_text = input("Which type path?","") as text
	if(!type_text) return
	var/type_path = text2path(type_text)
	if(!type_path) return

	var/count = 0

	for(var/atom/A in world)
		if(istype(A,type_path))
			count++
	/*
	var/atom/temp_atom
	for(var/i = 0; i <= (atom_list.len/10); i++)
		var/line = ""
		for(var/j = 1; j <= 10; j++)
			if(i*10+j <= atom_list.len)
				temp_atom = atom_list[i*10+j]
				line += " no.[i+10+j]@\[[temp_atom.x], [temp_atom.y], [temp_atom.z]\]; "
		log_debug(line) */

	log_debug("There are [count] objects of type [type_path] in the game world")
	SSstatistics.add_field_details("admin_verb","mOBJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//Special for Cakey
/client/proc/find_leaky_pipes()
	set category = "Mapping"
	set name = "Find Leaky Pipes"

	var/list/baddies = list("LEAKY PIPES")
	for(var/obj/machinery/atmospherics/pipe/P in SSmachines.machinery)
		if(P.leaking)
			baddies += "[P] ([P.x],[P.y],[P.z] - <A HREF='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[P.x];Y=[P.y];Z=[P.z]'>JMP</a>)"

	to_chat(usr,jointext(baddies, "<br>"))

/client/proc/show_cargo_prices()
	set category = "Debug"
	set name = "Debug Cargo Prices"

	var/list/cargo_packs = decls_repository.get_decls_of_subtype(/decl/hierarchy/supply_pack)
	var/list/prices = list()
	for(var/ptype in cargo_packs)
		var/decl/hierarchy/supply_pack/pack = cargo_packs[ptype]
		if(pack.name && !isnull(pack.cost))
			prices += "<tr><td>[pack.name]</td><td>[pack.cost]</td></tr>"

	var/datum/browser/popup = new(mob, "cargo_price_debug", "Cargo Prices")
	popup.set_content("<table>[jointext(prices, "")]</table>")
	popup.open()

#undef GET_ZAS_IMAGE