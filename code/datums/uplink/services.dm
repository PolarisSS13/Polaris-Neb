/***********
* Services *
************/
/datum/uplink_item/item/services
	category = /datum/uplink_category/services

/datum/uplink_item/item/services/fake_ion_storm
	name = "Ion Storm Announcement"
	desc = "A single-use device, that when activated, fakes an announcement, so people think all their electronic readings are wrong."
	item_cost = 8
	path = /obj/item/uplink_service/fake_ion_storm

/datum/uplink_item/item/services/suit_sensor_garble
	name = "Complete Suit Sensor Jamming"
	desc = "A single-use device, that when activated, garbles all suit sensor data for 10 minutes."
	item_cost = 16
	path = /obj/item/uplink_service/jamming/garble

/datum/uplink_item/item/services/fake_rad_storm
	name = "Radiation Storm Announcement"
	desc = "A single-use device, that when activated, fakes an announcement, so people run to the tunnels in fear of being irradiated! "
	item_cost = 24
	path = /obj/item/uplink_service/fake_rad_storm

/datum/uplink_item/item/services/fake_crew_annoncement
	name = "Crew Arrival Announcement and Records"
	desc = "A single-use device, that when activated, creates a fake crew arrival announcement as well as fake crew records, using your current appearance (including held items!) and worn id card. Prepare well!"
	item_cost = 16
	path = /obj/item/uplink_service/fake_crew_announcement

/datum/uplink_item/item/services/suit_sensor_shutdown
	name = "Complete Suit Sensor Shutdown"
	desc = "A single-use device, that when activated, completely disables all suit sensors for 10 minutes."
	item_cost = 40
	path = /obj/item/uplink_service/jamming

/datum/uplink_item/item/services/fake_update_annoncement
	item_cost = 40
	path = /obj/item/uplink_service/fake_update_announcement

/datum/uplink_item/item/services/fake_update_annoncement/New()
	..()
	item_cost = round(DEFAULT_TELECRYSTAL_AMOUNT / 2)
	addtimer(CALLBACK(src, PROC_REF(finalize_announce)), 2)

/datum/uplink_item/item/services/fake_update_annoncement/proc/finalize_announce()
	name = "[global.using_map.boss_name] Update Announcement"
	desc = "Causes a falsified [global.using_map.boss_name] Update."

/***************
* Service Item *
***************/

#define AWAITING_ACTIVATION 0
#define CURRENTLY_ACTIVE 1
#define HAS_BEEN_ACTIVATED 2

/obj/item/uplink_service
	name = "tiny device"
	desc = "Press button to activate. Can be done once and only once."
	w_class = ITEM_SIZE_TINY
	icon = 'icons/obj/items/device/flash_synthetic.dmi'
	icon_state = ICON_STATE_WORLD
	max_health = ITEM_HEALTH_NO_DAMAGE
	var/state = AWAITING_ACTIVATION
	var/service_label = "Unnamed Service"
	var/service_duration = 0 SECONDS

/obj/item/uplink_service/Destroy()
	if(state == CURRENTLY_ACTIVE)
		deactivate()
	. = ..()

/obj/item/uplink_service/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(distance <= 1)
		switch(state)
			if(AWAITING_ACTIVATION)
				LAZYADD(., "It is labeled '[service_label]' and appears to be awaiting activation.")
			if(CURRENTLY_ACTIVE)
				LAZYADD(., "It is labeled '[service_label]' and appears to be active.")
			if(HAS_BEEN_ACTIVATED)
				LAZYADD(., "It is labeled '[service_label]' and appears to be permanently disabled.")

/obj/item/uplink_service/attack_self(var/mob/user)
	if(state != AWAITING_ACTIVATION)
		to_chat(user, "<span class='warning'>\The [src] won't activate again.</span>")
		return
	var/obj/effect/overmap/visitable/O = global.overmap_sectors[num2text(get_z(src))]
	var/choice = alert(user, "This will only affect your current location[istype(O) ? " ([O])" : ""]. Proceed?","Confirmation", "Yes", "No")
	if(choice != "Yes")
		return
	if(!enable())
		return
	state = CURRENTLY_ACTIVE
	update_icon()
	user.visible_message("<span class='notice'>\The [user] activates \the [src].</span>", "<span class='notice'>You activate \the [src].</span>")
	log_and_message_admins("has activated the service '[service_label]'", user)

	if(service_duration)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/uplink_service, deactivate)), service_duration)
	else
		deactivate()

/obj/item/uplink_service/proc/deactivate()
	if(state != CURRENTLY_ACTIVE)
		return
	disable()
	state = HAS_BEEN_ACTIVATED
	update_icon()
	playsound(loc, "sparks", 50, 1)
	visible_message("<span class='warning'>\The [src] shuts down with a spark.</span>")

/obj/item/uplink_service/on_update_icon()
	. = ..()
	icon_state = get_world_inventory_state()
	switch(state)
		if(CURRENTLY_ACTIVE)
			icon_state = "[icon_state]-on"
		if(HAS_BEEN_ACTIVATED)
			icon_state = "[icon_state]-burnt"

/obj/item/uplink_service/proc/enable(var/mob/user = usr)
	return TRUE

/obj/item/uplink_service/proc/disable(var/mob/user = usr)
	return

/*****************
* Sensor Jamming *
*****************/
/obj/item/uplink_service/jamming
	service_duration = 10 MINUTES
	service_label = "Suit Sensor Shutdown"
	var/suit_sensor_jammer_method/ssjm = /suit_sensor_jammer_method/cap_off

/obj/item/uplink_service/jamming/Initialize()
	. = ..()
	ssjm = new ssjm()

/obj/item/uplink_service/jamming/Destroy()
	qdel(ssjm)
	ssjm = null
	. = ..()

/obj/item/uplink_service/jamming/enable(var/mob/user = usr)
	ssjm.enable()
	. = ..()

/obj/item/uplink_service/jamming/disable(var/mob/user = usr)
	ssjm.disable()

/obj/item/uplink_service/jamming/garble
	service_label = "Suit Sensor Garble"
	ssjm = /suit_sensor_jammer_method/random/moderate

/*****************
* Fake Ion storm *
*****************/
/obj/item/uplink_service/fake_ion_storm
	service_label = "Ion Storm Announcement"

/obj/item/uplink_service/fake_ion_storm/enable(var/mob/user = usr)
	ion_storm_announcement(SSmapping.get_connected_levels(get_z(src)))
	. = ..()

/*****************
* Fake Rad storm *
*****************/
/obj/item/uplink_service/fake_rad_storm
	service_label = "Radiation Storm Announcement"

/obj/item/uplink_service/fake_rad_storm/enable(var/mob/user = usr)
	var/datum/event_meta/EM = new(EVENT_LEVEL_MUNDANE, "Fake Radiation Storm", add_to_queue = 0)
	new/datum/event/radiation_storm/syndicate(EM)
	. = ..()

/***************************
* Fake CentCom Annoncement *
***************************/
/obj/item/uplink_service/fake_update_announcement
	service_label = "Update Announcement"

/obj/item/uplink_service/fake_update_announcement/enable(var/mob/user = usr)
	var/title = sanitize(input(user, "Enter your announcement title.", "Announcement Title") as null|text)
	if(!title)
		return
	var/message = sanitize(input(user, "Enter your announcement message.", "Announcement Title") as null|text)
	if(!message)
		return

	if(CanUseTopic(user, global.hands_topic_state) != STATUS_INTERACTIVE)
		return FALSE
	command_announcement.Announce(message, title, msg_sanitized = 1, zlevels = SSmapping.get_connected_levels(get_z(src)))
	return TRUE

/*********************************
* Fake Crew Records/Announcement *
*********************************/
/obj/item/uplink_service/fake_crew_announcement
	service_label = "Crew Arrival Announcement and Records"

#define COPY_VALUE(KEY) new_record.set_##KEY(random_record.get_##KEY())

/obj/item/uplink_service/fake_crew_announcement/enable(var/mob/user = usr)

	var/datum/computer_file/report/crew_record/random_record
	var/obj/item/card/id/I = user.GetIdCard()
	var/datum/computer_network/net = get_local_network_at(get_turf(user))
	if(net && length(net.get_crew_records()))
		random_record = pick(net.get_crew_records())
	var/datum/computer_file/report/crew_record/new_record = CreateModularRecord(user)
	if(I)
		new_record.set_name(I.registered_name)
		new_record.set_formal_name("[I.formal_name_prefix][I.registered_name][I.formal_name_suffix]")
		new_record.set_gender(I.card_gender)
		new_record.set_age(I.age)
		new_record.set_job(I.assignment)
		new_record.set_fingerprint(I.fingerprint_hash)
		new_record.set_bloodtype(I.blood_type)
		new_record.set_dna(I.dna_hash)
		if(I.military_branch)
			new_record.set_branch(I.military_branch.name)
			if(I.military_rank)
				new_record.set_rank(I.military_rank.name)
				new_record.set_formal_name("[I.registered_name][I.formal_name_suffix]") // Rank replaces formal name prefix in real manifest entries
	if(random_record)
		COPY_VALUE(faction)
		COPY_VALUE(religion)
		COPY_VALUE(residence)
		COPY_VALUE(fingerprint)
		COPY_VALUE(dna)
		COPY_VALUE(bloodtype)
	var/datum/job/job = SSjobs.get_by_title(new_record.get_job())
	if(job)
		var/skills = list()
		for(var/decl/skill/S in global.using_map.get_available_skills())
			var/level = job.min_skill[S.type]
			if(prob(10))
				level = min(rand(1,3), job.max_skill[S.type])
			if(level > SKILL_NONE)
				skills += "[S.name], [S.levels[level]]"
		new_record.set_skillset(jointext(skills,"\n"))

	if(istype(job) && job.announced)
		var/announce_channel = get_announcement_frequency(job)
		if(announce_channel)
			do_telecomms_announcement(user, "[new_record.get_name()], [new_record.get_job()], has completed cryogenic revival.", "Arrivals Announcement Computer", announce_channel)
	. = ..()

#undef COPY_VALUE
