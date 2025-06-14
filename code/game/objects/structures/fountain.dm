//the fountain of youth/unyouth

/obj/structure/fountain
	name        = "strange fountain"
	desc        = "The water from the spout is still as if frozen in time, yet the water in the base ripples perpetually."
	icon        = 'icons/obj/fountain.dmi'
	icon_state  = "fountain"
	density     = TRUE
	anchored    = TRUE
	pixel_x     = -16
	light_range = 5
	light_power = 0.5
	var/used    = FALSE
	var/increase_age_prob = (100 / 6)

/obj/structure/fountain/Initialize(ml, _mat, _reinf_mat)
	if(light_range && light_power)
		light_color = get_random_colour(lower = 190)
	. = ..()

/obj/structure/fountain/attack_hand(var/mob/user)

	if(user.check_intent(I_FLAG_HARM))
		return ..()

	if(used)
		to_chat(user,  SPAN_WARNING("\The [src] is still and lifeless..."))
		return TRUE

	var/mob/living/human/H = user
	var/decl/bodytype/my_bodytype = istype(H) && H.get_bodytype()
	if(!istype(my_bodytype))
		return ..()

	var/datum/appearance_descriptor/age/age = my_bodytype && LAZYACCESS(my_bodytype.appearance_descriptors, "age")
	if(H.isSynthetic() || !my_bodytype || !age)
		to_chat(H, SPAN_WARNING("A feeling of foreboding stills your hand. The fountain is not for your kind."))
		return TRUE

	if(alert("As you reach out to touch the fountain, a feeling of doubt overcomes you. Steel yourself and proceed?",,"Yes", "No") == "Yes")
		visible_message("\The [H] touches \the [src].")
		time_dilation(H)
	else
		visible_message("\The [H] retracts their hand suddenly.")
	return TRUE

/obj/structure/fountain/proc/time_dilation(var/mob/living/human/user)

	for(var/mob/living/L in oviewers(7, src))
		L.flash_eyes(3)
		SET_STATUS_MAX(L, STAT_BLURRY, 9)

	visible_message(SPAN_WARNING("\The [src] erupts in a bright flash of light!"))
	playsound(src,'sound/items/time.ogg',100)

	var/old_age = user.get_age()
	var/new_age = old_age
	if(prob(increase_age_prob))
		new_age += rand(5,15)
	else
		new_age -= rand(5,15)

	var/decl/bodytype/bodytype = user.get_bodytype()
	var/datum/appearance_descriptor/age/age = LAZYACCESS(bodytype.appearance_descriptors, "age")
	// Let's avoid reverting people to children since that has a lot of baggage attached.
	var/min_age = age.standalone_value_descriptors[age.standalone_value_descriptors[age.chargen_min_index]]
	new_age = max(new_age, min_age) // This will clamp to the max defined age already so only need to min()

	if(new_age == old_age)
		to_chat(user, SPAN_CULT_ANNOUNCE("You touch the fountain, and feel your memories sifted through by a great presence. Then, it withdraws, leaving you unchanged."))
	else
		user.set_age(new_age)
		if(new_age < old_age)
			to_chat(user, SPAN_CULT_ANNOUNCE("You touch the fountain. Everything stops - then reverses. You relive in an instant the events of your life. The fountain, yesterday's lunch, your first love, your first kiss. It all feels as though it just happened moments ago. Then it feels like it never happened at all. Time reverses back into normality and continues its advance. You feel great, but why are you here?"))
			user.became_younger = TRUE
		else
			to_chat(user, SPAN_CULT_ANNOUNCE("You touch the fountain. All the memories of your life seem to fade into the distant past as seconds drag like years. You feel the inexplicable sensation of your skin tightening and thinning across your entire body as your muscles degrade and your joints weaken. Time returns to its 'normal' pace. You can only just barely remember touching the fountain."))
			user.became_older = TRUE
			SET_HAIR_COLOR(user, COLOR_GRAY80, FALSE)
			var/max_age = age.standalone_value_descriptors[age.standalone_value_descriptors[length(age.standalone_value_descriptors)]]
			if(new_age >= max_age)
				to_chat(user, SPAN_CULT_ANNOUNCE("<b>The burden of the years is too much, and you are reduced to dust.</b>"))
				user.dust()

	used = TRUE
	desc = "The water flows beautifully from the spout, but the water in the pool does not ripple."

/mob/living/human
	/// Used by the Fountain of Youth point of interest for on-examine messages.
	var/became_older
	/// Used by the Fountain of Youth point of interest for on-examine messages.
	var/became_younger

/decl/human_examination/fountain
	priority = /decl/human_examination/graffiti::priority + 0.5 // just squeeze it in there

/decl/human_examination/fountain/do_examine(mob/user, distance, mob/living/human/source, hideflags, decl/pronouns/pronouns)
	. = list()
	if(source.became_younger)
		. += "[pronouns.He] look[pronouns.s] a lot younger than you remember."
	if(source.became_older)
		. += "[pronouns.He] look[pronouns.s] a lot older than you remember."

/obj/structure/fountain/mundane
	name                   = "fountain"
	desc                   = "A beautifully constructed fountain."
	icon_state             = "fountain_g"
	tool_interaction_flags = TOOL_INTERACTION_DECONSTRUCT
	w_class                = ITEM_SIZE_STRUCTURE
	material               = /decl/material/solid/stone/marble
	used                   = TRUE
	material_alteration    = MAT_FLAG_ALTERATION_ALL
	atom_flags             = ATOM_FLAG_OPEN_CONTAINER | ATOM_FLAG_CLIMBABLE
	light_range            = null
	light_power            = null

/obj/structure/fountain/mundane/Initialize(ml, _mat, _reinf_mat)
	. = ..()
	initialize_reagents(ml)

/obj/structure/fountain/mundane/initialize_reagents(populate = TRUE)
	create_reagents(500)
	. = ..()

/obj/structure/fountain/mundane/populate_reagents()
	add_to_reagents(/decl/material/liquid/water, reagents.maximum_volume) //Don't give free water when building one

/obj/structure/fountain/mundane/attack_hand(mob/user)
	if(user.check_intent(I_FLAG_HARM))
		return ..()
	return TRUE

/obj/structure/fountain/mundane/sandstone
	material = /decl/material/solid/stone/sandstone
	color = /decl/material/solid/stone/sandstone::color
