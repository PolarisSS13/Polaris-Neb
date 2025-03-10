//A 'wound' system for space suits.
//Breaches greatly increase the amount of lost gas and decrease the armour rating of the suit.
//They can be healed with plastic or metal sheeting.

/datum/breach
	var/class = 0                           // Size. Lower is smaller. Uses floating point values!
	var/descriptor                          // 'gaping hole' etc.
	var/damtype = BURN                      // Punctured or melted
	var/patched = FALSE
	var/obj/item/clothing/suit/space/holder // Suit containing the list of breaches holding this instance.
	var/static/list/breach_brute_descriptors = list(
		"tiny puncture",
		"ragged tear",
		"large split",
		"huge tear",
		"gaping wound"
		)

	var/static/list/breach_burn_descriptors = list(
		"small burn",
		"melted patch",
		"sizable burn",
		"large scorched area",
		"huge scorched area"
		)

/obj/item/clothing/suit/space
	var/can_breach = 1                      // Set to 0 to disregard all breaching.
	var/list/breaches = list()              // Breach datum container.
	var/resilience = 0.2                    // Multiplier that turns damage into breach class. 1 is 100% of damage to breach, 0.1 is 10%. 0.2 -> 50 brute/burn damage to cause 10 breach damage
	var/breach_threshold = 3                // Min damage before a breach is possible. Damage is subtracted by this amount, it determines the "hardness" of the suit.
	var/damage = 0                          // Current total damage. Does not count patched breaches.
	var/brute_damage = 0                    // Specifically brute damage. Includes patched punctures.
	var/burn_damage = 0                     // Specifically burn damage. Includes patched burns.

/datum/breach/proc/update_descriptor()

	//Sanity...
	class = clamp(round(class), 1, 5)
	//Apply the correct descriptor.
	if(damtype == BURN)
		descriptor = breach_burn_descriptors[class]
	else if(damtype == BRUTE)
		descriptor = breach_brute_descriptors[class]
	if(patched)
		descriptor = "patched [descriptor]"

//Repair a certain amount of brute or burn damage to the suit.
/obj/item/clothing/suit/space/proc/repair_breaches(var/damtype, var/amount, var/mob/user)

	if(!can_breach || !breaches || !breaches.len)
		to_chat(user, "There are no breaches to repair on \the [src].")
		return

	var/list/valid_breaches = list()

	for(var/datum/breach/B in breaches)
		if(B.damtype == damtype)
			valid_breaches += B

	if(!valid_breaches.len)
		to_chat(user, "There are no breaches to repair on \the [src].")
		return

	var/amount_left = amount
	for(var/datum/breach/B in valid_breaches)
		if(!amount_left) break

		if(B.class <= amount_left)
			amount_left -= B.class
			valid_breaches -= B
			breaches -= B
		else
			B.class	-= amount_left
			amount_left = 0
			B.update_descriptor()

	user.visible_message(
		SPAN_NOTICE("\The [user] patches some of the damage on \the [src]."),
		SPAN_NOTICE("You patch some of the damage on \the [src].")
	)
	calc_breach_damage()

/obj/item/clothing/suit/space/proc/create_breaches(var/damtype, var/amount)

	amount -= src.breach_threshold
	amount *= src.resilience

	if(!can_breach || amount <= 0)
		return

	if(!breaches)
		breaches = list()

	if(damage > 25) return //We don't need to keep tracking it when it's at 250% pressure loss, really.

	//Increase existing breaches.
	for(var/datum/breach/existing in breaches)

		if(existing.damtype != damtype)
			continue

		//keep in mind that 10 breach damage == full pressure loss.
		//a breach can have at most 5 breach damage
		if (existing.class < 5)
			var/needs = 5 - existing.class
			if(amount < needs)
				existing.class += amount
				amount = 0
			else
				existing.class = 5
				amount -= needs

			if(existing.damtype == BRUTE)
				var/message = "\The [existing.descriptor] on \the [src] gapes wider[existing.patched ? ", tearing the patch" : ""]!"
				visible_message(SPAN_WARNING(message))
			else if(existing.damtype == BURN)
				var/message = "\The [existing.descriptor] on \the [src] widens[existing.patched ? ", ruining the patch" : ""]!"
				visible_message(SPAN_WARNING(message))

			existing.patched = FALSE

	if (amount)
		//Spawn a new breach.
		var/datum/breach/B = new()
		breaches += B

		B.class = min(amount,5)

		B.damtype = damtype
		B.update_descriptor()
		B.holder = src

		if(B.damtype == BRUTE)
			visible_message(SPAN_WARNING("\A [B.descriptor] opens up on \the [src]!"))
		else if(B.damtype == BURN)
			visible_message(SPAN_WARNING("\A [B.descriptor] marks the surface of \the [src]!"))

	calc_breach_damage()

//Calculates the current extent of the damage to the suit.
/obj/item/clothing/suit/space/proc/calc_breach_damage()

	damage = 0
	brute_damage = 0
	burn_damage = 0
	var/all_patched = TRUE

	if(!can_breach || !breaches || !breaches.len)
		SetName(initial(name))
		return 0

	for(var/datum/breach/B in breaches)
		if(!B.class)
			src.breaches -= B
			qdel(B)
		else
			if(!B.patched)
				all_patched = FALSE
				damage += B.class

			if(B.damtype == BRUTE)
				brute_damage += B.class
			else if(B.damtype == BURN)
				burn_damage += B.class

	if(damage >= 3)
		if(brute_damage >= 3 && brute_damage > burn_damage)
			SetName("punctured [initial(name)]")
		else if(burn_damage >= 3 && burn_damage > brute_damage)
			SetName("scorched [initial(name)]")
		else
			SetName("damaged [initial(name)]")
	else if(all_patched)
		SetName("patched [initial(name)]")
	else
		SetName(initial(name))

	return damage

//Handles repairs (and also upgrades).

/obj/item/clothing/suit/space/attackby(obj/item/used_item, mob/user)
	if(istype(used_item,/obj/item/stack/material))
		var/repair_power = 0
		switch(used_item.get_material_type())
			if(/decl/material/solid/metal/steel)
				repair_power = 2
			if(/decl/material/solid/organic/plastic)
				repair_power = 1

		if(!repair_power)
			return FALSE

		if(ishuman(loc))
			var/mob/living/human/H = loc
			if(H.get_equipped_item(slot_wear_suit_str) == src)
				to_chat(user, SPAN_WARNING("You cannot repair \the [src] while it is being worn."))
				return TRUE

		if(burn_damage <= 0)
			to_chat(user, "There is no surface damage on \the [src] to repair.") //maybe change the descriptor to more obvious? idk what
			return TRUE

		var/obj/item/stack/P = used_item
		var/use_amt = min(P.get_amount(), 3)
		if(use_amt && P.use(use_amt))
			repair_breaches(BURN, use_amt * repair_power, user)
		return TRUE

	else if(IS_WELDER(used_item))

		if(ishuman(loc))
			var/mob/living/human/H = loc
			if(H.get_equipped_item(slot_wear_suit_str) == src)
				to_chat(user, SPAN_WARNING("You cannot repair \the [src] while it is being worn."))
				return TRUE

		if (brute_damage <= 0)
			to_chat(user, "There is no structural damage on \the [src] to repair.")
			return TRUE

		var/obj/item/weldingtool/welder = used_item
		if(!welder.weld(5))
			to_chat(user, SPAN_WARNING("You need more welding fuel to repair this suit."))
			return TRUE

		repair_breaches(BRUTE, 3, user)
		return TRUE

	else if(istype(used_item, /obj/item/stack/tape_roll/duct_tape))
		var/datum/breach/target_breach		//Target the largest unpatched breach.
		for(var/datum/breach/B in breaches)
			if(B.patched)
				continue
			if(!target_breach || (B.class > target_breach.class))
				target_breach = B

		if(!target_breach)
			to_chat(user, "There are no open breaches to seal with \the [used_item].")
		else
			var/obj/item/stack/tape_roll/duct_tape/D = used_item
			var/amount_needed = ceil(target_breach.class * 2)
			if(!D.can_use(amount_needed))
				to_chat(user, SPAN_WARNING("There's not enough [D.plural_name] in your [src] to seal \the [target_breach.descriptor] on \the [src]! You need at least [amount_needed] [D.plural_name]."))
				return TRUE

			if(do_after(user, user.get_equipped_item(slot_wear_suit_str) == src? 6 SECONDS : 3 SECONDS, isliving(loc)? loc : null)) //Sealing a breach on your own suit is awkward and time consuming
				D.use(amount_needed)
				playsound(src, 'sound/effects/tape.ogg',25)
				user.visible_message(
					SPAN_NOTICE("\The [user] uses some [D.plural_name] to seal \the [target_breach.descriptor] on \the [src]."),
					SPAN_NOTICE("You use [amount_needed] [D.plural_name] of \the [used_item] to seal \the [target_breach.descriptor] on \the [src].")
				)
				target_breach.patched = TRUE
				target_breach.update_descriptor()
				calc_breach_damage()
		return TRUE
	return ..()

/obj/item/clothing/suit/space/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(can_breach && breaches && breaches.len)
		for(var/datum/breach/B in breaches)
			. += SPAN_DANGER("It has \a [B.descriptor].")

/obj/item/clothing/suit/space/get_pressure_weakness(pressure)
	. = ..()
	if(can_breach && damage)
		. = min(1, . + damage*0.1)
