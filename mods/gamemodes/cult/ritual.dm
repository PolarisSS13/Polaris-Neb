/obj/item/book/tome
	name              = "arcane tome"
	icon              = 'icons/obj/items/tome.dmi'
	icon_state        = "tome"
	throw_speed       = 1
	throw_range       = 5
	w_class           = ITEM_SIZE_SMALL
	unique            = TRUE
	can_dissolve_text = FALSE

/obj/item/book/tome/try_carve(mob/user, obj/item/tool)
	return

/obj/item/book/tome/attack_self(var/mob/user)
	if(!iscultist(user))
		to_chat(user, "\The [src] seems full of illegible scribbles. Is this a joke?")
	else
		to_chat(user, "Hold \the [src] in your hand while drawing a rune to use it.")

/obj/item/book/tome/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(iscultist(user))
		. += "The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Contains the details of every ritual his followers could think of. Most of these are useless, though."
	else
		. += "An old, dusty tome with frayed edges and a sinister looking cover."

/obj/item/book/tome/afterattack(var/atom/A, var/mob/user, var/proximity)
	if(!proximity || !iscultist(user))
		return
	if(A.reagents && A.reagents.has_reagent(/decl/material/liquid/water))
		to_chat(user, SPAN_NOTICE("You desecrate \the [A]."))
		LAZYSET(A.reagents.reagent_data, /decl/material/liquid/water, list("holy" = FALSE))

/mob/proc/make_rune(var/rune, var/cost = 5, var/tome_required = 0)
	var/has_robes = 0
	var/cult_ground = 0

	var/has_tome = locate(/obj/item/book/tome) in get_held_items()
	if(tome_required && mob_needs_tome() && !has_tome)
		to_chat(src, "<span class='warning'>This rune is too complex to draw by memory, you need to have a tome in your hand to draw it.</span>")
		return
	if(istype(get_equipped_item(slot_head_str), /obj/item/clothing/head/culthood) && istype(get_equipped_item(slot_wear_suit_str), /obj/item/clothing/suit/cultrobes) && istype(get_equipped_item(slot_shoes_str), /obj/item/clothing/shoes/cult))
		has_robes = 1
	var/turf/T = get_turf(src)
	if(is_holy_turf(T))
		to_chat(src, "<span class='warning'>This place is blessed, you may not draw runes on it - defile it first.</span>")
		return
	if(!T.simulated)
		to_chat(src, "<span class='warning'>You need more space to draw a rune here.</span>")
		return
	if(locate(/obj/effect/rune) in T)
		to_chat(src, "<span class='warning'>There's already a rune here.</span>") // Don't cross the runes
		return
	if(T.is_defiled())
		cult_ground = 1
	var/self
	var/timer
	var/damage = 1
	if(has_tome)
		if(has_robes && cult_ground)
			self = "Feeling greatly empowered, you slice open your finger and make a rune on the engraved floor. It shifts when your blood touches it, and starts vibrating as you begin to chant the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
			timer = 10
			damage = 0.2
		else if(has_robes)
			self = "Feeling empowered in your robes, you slice open your finger and start drawing a rune, chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
			timer = 30
			damage = 0.8
		else if(cult_ground)
			self = "You slice open your finger and slide it over the engraved floor, watching it shift when your blood touches it. It vibrates when you begin to chant the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world." // Sadly, you don't have access to the bell nor the candelbarum
			timer = 20
			damage = 0.8
		else
			self = "You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
			timer = 40
	else
		self = "Working without your tome, you try to draw the rune from your memory"
		if(has_robes && cult_ground)
			self += ". You feel that you remember it perfectly, finishing it with a few bold strokes. The engraved floor shifts under your touch, and vibrates once you begin your chants."
			timer = 30
		else if(has_robes)
			self += ". You don't remember it well, but you feel strangely empowered. You begin chanting, the unknown words slipping into your mind from beyond."
			timer = 50
		else if(cult_ground)
			self += ", watching as the floor shifts under your touch, correcting the rune. You begin your chants, and the ground starts to vibrate."
			timer = 40
		else
			self += ", having to cut your finger two more times before you make it resemble the pattern in your memory. It still looks a little off."
			timer = 80
			damage = 2
	visible_message("<span class='warning'>\The [src] slices open a finger and begins to chant and paint symbols on the floor.</span>", "<span class='notice'>[self]</span>", "You hear chanting.")
	if(do_after(src, timer))
		remove_blood(cost * damage)
		if(locate(/obj/effect/rune) in T)
			return
		var/obj/effect/rune/R = new rune(T, get_blood_color(), get_blood_name())
		var/area/A = get_area(R)
		log_and_message_admins("created \an [R.cultname] rune at \the [A.proper_name].")
		R.add_fingerprint(src)
		return 1
	return 0

/mob/living/human/make_rune(var/rune, var/cost, var/tome_required)
	if(should_have_organ(BP_HEART) && vessel && vessel.total_volume < species.blood_volume * 0.7)
		to_chat(src, "<span class='danger'>You are too weak to draw runes.</span>")
		return
	..()

/mob/proc/mob_needs_tome()
	return FALSE

/mob/living/human/mob_needs_tome()
	return TRUE

var/global/list/Tier1Runes = list(
	/mob/proc/convert_rune,
	/mob/proc/teleport_rune,
	/mob/proc/tome_rune,
	/mob/proc/wall_rune,
	/mob/proc/ajorney_rune,
	/mob/proc/defile_rune,
	/mob/proc/stun_imbue,
	/mob/proc/emp_imbue,
	/mob/proc/cult_communicate,
	/mob/proc/obscure,
	/mob/proc/reveal
	)

var/global/list/Tier2Runes = list(
	/mob/proc/armor_rune,
	/mob/proc/offering_rune,
	/mob/proc/drain_rune,
	/mob/proc/emp_rune,
	/mob/proc/massdefile_rune
	)

var/global/list/Tier3Runes = list(
	/mob/proc/weapon_rune,
	/mob/proc/shell_rune,
	/mob/proc/bloodboil_rune,
	/mob/proc/confuse_rune,
	/mob/proc/revive_rune
)

var/global/list/Tier4Runes = list(
	/mob/proc/tearreality_rune
	)

/mob/proc/convert_rune()
	set category = "Cult Magic"
	set name = "Rune: Convert"

	make_rune(/obj/effect/rune/convert, tome_required = 1)

/mob/proc/teleport_rune()
	set category = "Cult Magic"
	set name = "Rune: Teleport"

	make_rune(/obj/effect/rune/teleport, tome_required = 1)

/mob/proc/tome_rune()
	set category = "Cult Magic"
	set name = "Rune: Summon Tome"

	make_rune(/obj/effect/rune/tome, cost = 15)

/mob/proc/wall_rune()
	set category = "Cult Magic"
	set name = "Rune: Wall"

	make_rune(/obj/effect/rune/wall, tome_required = 1)

/mob/proc/ajorney_rune()
	set category = "Cult Magic"
	set name = "Rune: Astral Journey"

	make_rune(/obj/effect/rune/ajorney)

/mob/proc/defile_rune()
	set category = "Cult Magic"
	set name = "Rune: Defile"

	make_rune(/obj/effect/rune/defile, tome_required = 1)

/mob/proc/massdefile_rune()
	set category = "Cult Magic"
	set name = "Rune: Mass Defile"

	make_rune(/obj/effect/rune/massdefile, tome_required = 1, cost = 20)

/mob/proc/armor_rune()
	set category = "Cult Magic"
	set name = "Rune: Summon Robes"

	make_rune(/obj/effect/rune/armor, tome_required = 1)

/mob/proc/offering_rune()
	set category = "Cult Magic"
	set name = "Rune: Offering"

	make_rune(/obj/effect/rune/offering, tome_required = 1)



/mob/proc/drain_rune()
	set category = "Cult Magic"
	set name = "Rune: Blood Drain"

	make_rune(/obj/effect/rune/drain, tome_required = 1)

/mob/proc/emp_rune()
	set category = "Cult Magic"
	set name = "Rune: EMP"

	make_rune(/obj/effect/rune/emp, tome_required = 1)

/mob/proc/weapon_rune()
	set category = "Cult Magic"
	set name = "Rune: Summon Weapon"

	make_rune(/obj/effect/rune/weapon, tome_required = 1)

/mob/proc/shell_rune()
	set category = "Cult Magic"
	set name = "Rune: Summon Shell"

	make_rune(/obj/effect/rune/shell, cost = 10, tome_required = 1)

/mob/proc/bloodboil_rune()
	set category = "Cult Magic"
	set name = "Rune: Blood Boil"

	make_rune(/obj/effect/rune/blood_boil, cost = 20, tome_required = 1)

/mob/proc/confuse_rune()
	set category = "Cult Magic"
	set name = "Rune: Confuse"

	make_rune(/obj/effect/rune/confuse)

/mob/proc/revive_rune()
	set category = "Cult Magic"
	set name = "Rune: Revive"

	make_rune(/obj/effect/rune/revive, tome_required = 1)

/mob/proc/tearreality_rune()
	set category = "Cult Magic"
	set name = "Rune: Tear Reality"

	make_rune(/obj/effect/rune/tearreality, cost = 50, tome_required = 1)

/mob/proc/stun_imbue()
	set category = "Cult Magic"
	set name = "Imbue: Stun"

	make_rune(/obj/effect/rune/imbue/stun, cost = 20, tome_required = 1)

/mob/proc/emp_imbue()
	set category = "Cult Magic"
	set name = "Imbue: EMP"

	make_rune(/obj/effect/rune/imbue/emp)

/mob/proc/cult_communicate()
	set category = "Cult Magic"
	set name = "Communicate"

	if(incapacitated())
		to_chat(src, "<span class='warning'>Not when you are incapacitated.</span>")
		return

	message_cult_communicate()
	remove_blood(3)

	var/input = input(src, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input)
		return

	whisper("[input]")

	input = sanitize(input)
	log_and_message_admins("used a communicate verb to say '[input]'")
	var/decl/special_role/cult = GET_DECL(/decl/special_role/cultist)
	for(var/datum/mind/H in cult.current_antagonists)
		if(H.current && !H.current.stat)
			to_chat(H.current, "<span class='cult'>[input]</span>")

/mob/living/cult_communicate()
	if(incapacitated(INCAPACITATION_RESTRAINED))
		to_chat(src, "<span class='warning'>You need at least your hands free to do this.</span>")
		return
	..()

/mob/proc/message_cult_communicate()
	return

/mob/living/human/message_cult_communicate()
	var/decl/pronouns/pronouns = get_pronouns()
	visible_message(SPAN_WARNING("\The [src] cuts [pronouns.his] finger and starts drawing on the back of [pronouns.his] hand."))

/mob/proc/obscure()
	set category = "Cult Magic"
	set name = "Rune: Obscure"

	make_rune(/obj/effect/rune/obscure)

/mob/proc/reveal()
	set category = "Cult Magic"
	set name = "Rune: Reveal"

	make_rune(/obj/effect/rune/reveal)