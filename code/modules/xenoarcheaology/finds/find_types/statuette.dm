/decl/archaeological_find/statuette
	item_type = "statuette"
	new_icon_state = "statuette"
	possible_types = list(
		/obj/item = 4,
		/obj/item/vampiric
		)

/decl/archaeological_find/statuette/get_additional_description()
	return "It depicts a [pick("small","ferocious","wild","pleasing","hulking")] \
	[pick("alien figure","rodent-like creature","reptilian alien","primate","unidentifiable object")] \
	[pick("performing unspeakable acts","posing heroically","in a fetal position","cheering","sobbing","making a plaintive gesture","making a rude gesture")]."

// Vampiric statuette

/obj/item/vampiric
	name = "statuette"
	icon_state = "statuette"
	icon = 'icons/obj/xenoarchaeology.dmi'
	material = /decl/material/solid/stone/basalt
	var/charges = 0
	var/list/nearby_mobs = list()
	var/last_bloodcall = 0
	var/bloodcall_interval = 50
	var/last_eat = 0
	var/eat_interval = 100
	var/wight_check_index = 1
	var/list/shadow_wights = list()

/obj/item/vampiric/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	global.listening_objects += src

/obj/item/vampiric/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/vampiric/Process()
	//see if we've identified anyone nearby
	if(world.time - last_bloodcall > bloodcall_interval && nearby_mobs.len)
		var/mob/living/human/M = pop(nearby_mobs)
		if((M in viewers(7,src)) && M.current_health > 20)
			if(prob(50))
				bloodcall(M)
				nearby_mobs.Add(M)

	//suck up some blood to gain power
	if(world.time - last_eat > eat_interval)
		var/obj/effect/decal/cleanable/blood/B = locate() in range(2,src)
		if(B)
			last_eat = world.time
			if(istype(B, /obj/effect/decal/cleanable/blood/drip))
				charges += 0.25
			else
				charges += 1
				playsound(src.loc, 'sound/effects/splat.ogg', 50, 1, -3)
			qdel(B)

	//use up stored charges
	if(charges >= 10)
		charges -= 10
		new /obj/effect/spider/eggcluster(pick(view(1,src)))

	if(charges >= 3)
		if(prob(5))
			charges -= 1
			var/spawn_type = pick(/mob/living/simple_animal/hostile/creature)
			new spawn_type(pick(view(1,src)))
			playsound(src.loc, pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg'), 50, 1, -3)

	if(charges >= 1)
		if(shadow_wights.len < 5 && prob(5))
			shadow_wights.Add(new /obj/effect/shadow_wight(src.loc))
			playsound(src.loc, 'sound/effects/ghost.ogg', 50, 1, -3)
			charges -= 0.1

	if(charges >= 0.1)
		if(prob(5))
			src.visible_message("<span class='warning'>[html_icon(src)] [src]'s eyes glow ruby red for a moment!</span>")
			charges -= 0.1

	//check on our shadow wights
	if(shadow_wights.len)
		wight_check_index++
		if(wight_check_index > shadow_wights.len)
			wight_check_index = 1

		var/obj/effect/shadow_wight/wight = shadow_wights[wight_check_index]
		if(isnull(wight))
			shadow_wights.Remove(wight_check_index)
		else if(isnull(wight.loc))
			shadow_wights.Remove(wight_check_index)
		else if(get_dist(wight, src) > 10)
			shadow_wights.Remove(wight_check_index)

/obj/item/vampiric/hear_talk(mob/M, text)
	..()
	if(world.time - last_bloodcall >= bloodcall_interval && (M in view(7, src)))
		bloodcall(M)

/obj/item/vampiric/proc/bloodcall(var/mob/living/human/M)
	last_bloodcall = world.time
	if(istype(M))
		playsound(src.loc, pick('sound/hallucinations/wail.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/far_noise.ogg'), 50, 1, -3)
		nearby_mobs.Add(M)

		var/obj/item/organ/external/target = pick(M.get_external_organs())
		M.apply_damage(rand(5, 10), BRUTE, target.organ_tag)
		to_chat(M, "<span class='warning'>The skin on your [parse_zone(target.organ_tag)] feels like it's ripping apart, and a stream of blood flies out.</span>")
		var/obj/effect/decal/cleanable/blood/splatter/animated/B = new(M.loc)
		B.target_turf = pick(range(1, src))
		var/blood_type = M.get_blood_type()
		var/unique_enzymes = M.get_unique_enzymes()
		if(blood_type && unique_enzymes)
			LAZYSET(B.blood_DNA, unique_enzymes, blood_type)
		M.vessel.remove_any(rand(25,50))

//animated blood 2 SPOOKY
/obj/effect/decal/cleanable/blood/splatter/animated
	var/turf/target_turf
	var/loc_last_process

/obj/effect/decal/cleanable/blood/splatter/animated/Initialize()
	. = ..()
	loc_last_process = src.loc
	START_PROCESSING(SSobj, src)

/obj/effect/decal/cleanable/blood/splatter/animated/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/decal/cleanable/blood/splatter/animated/Process()
	if(target_turf && src.loc != target_turf)
		step_towards(src,target_turf)
		if(src.loc == loc_last_process)
			target_turf = null
		loc_last_process = src.loc

		//leave some drips behind
		if(prob(50))
			var/obj/effect/decal/cleanable/blood/drip/D = new(src.loc)
			D.blood_DNA = src.blood_DNA.Copy()
			if(prob(50))
				D = new(src.loc)
				D.blood_DNA = src.blood_DNA.Copy()
				if(prob(50))
					D = new(src.loc)
					D.blood_DNA = src.blood_DNA.Copy()
	else
		..()

/obj/effect/shadow_wight
	name = "shadow wight"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	density = TRUE

/obj/effect/shadow_wight/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/shadow_wight/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/shadow_wight/Process()
	if(loc)
		step_rand(src)
		var/mob/living/M = locate() in src.loc
		if(M)
			playsound(src.loc, pick('sound/hallucinations/behind_you1.ogg',\
			'sound/hallucinations/behind_you2.ogg',\
			'sound/hallucinations/i_see_you1.ogg',\
			'sound/hallucinations/i_see_you2.ogg',\
			'sound/hallucinations/im_here1.ogg',\
			'sound/hallucinations/im_here2.ogg',\
			'sound/hallucinations/look_up1.ogg',\
			'sound/hallucinations/look_up2.ogg',\
			'sound/hallucinations/over_here1.ogg',\
			'sound/hallucinations/over_here2.ogg',\
			'sound/hallucinations/over_here3.ogg',\
			'sound/hallucinations/turn_around1.ogg',\
			'sound/hallucinations/turn_around2.ogg',\
			), 50, 1, -3)
			SET_STATUS_MAX(M, STAT_ASLEEP, rand(5,10))
			qdel(src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/effect/shadow_wight/Bump(var/atom/obstacle)
	to_chat(obstacle, "<span class='warning'>You feel a chill run down your spine!</span>")
