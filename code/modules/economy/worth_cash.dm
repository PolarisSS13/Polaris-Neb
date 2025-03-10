/obj/item/cash
	name = "cash"
	desc = "Some cold hard cash."
	icon = 'icons/obj/items/money.dmi'
	icon_state = "cash"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	throw_speed = 1
	throw_range = 2
	w_class = ITEM_SIZE_TINY
	material = /decl/material/solid/organic/plastic
	var/currency
	var/absolute_worth = 0
	var/can_flip = TRUE // Cooldown tracker for single-coin flips.
	var/static/overlay_cap = 50 // Max overlays to show in this pile.

/obj/item/cash/Initialize(ml, material_key, starting_amount)

	if(!isnull(starting_amount))
		absolute_worth = starting_amount

	. = ..()

	if(!ispath(currency, /decl/currency))
		currency = global.using_map.default_currency

	if(!ispath(currency, /decl/currency))
		return INITIALIZE_HINT_QDEL

	if(isturf(loc))
		for(var/obj/item/cash/other in loc)
			if(other == src)
				continue
			if(other.currency != currency)
				continue
			other.absolute_worth += absolute_worth
			other.update_from_worth()
			return INITIALIZE_HINT_QDEL

	if(absolute_worth > 0)
		update_from_worth()

/obj/item/cash/get_base_value()
	. = holographic ? 0 : absolute_worth

/obj/item/cash/proc/set_currency(var/new_currency)
	currency = new_currency
	update_from_worth()

/obj/item/cash/proc/adjust_worth(var/amt)
	absolute_worth += amt
	if(absolute_worth <= 0)
		qdel(src)
	else
		update_from_worth()

/obj/item/cash/proc/get_worth()
	var/decl/currency/cur = GET_DECL(currency)
	. = floor(absolute_worth / cur.absolute_value)

/obj/item/cash/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, /obj/item/cash))
		var/obj/item/cash/cash = used_item
		if(cash.currency != currency)
			to_chat(user, SPAN_WARNING("You can't mix two different currencies, it would be uncivilized."))
			return TRUE
		if(user.try_unequip(used_item))
			adjust_worth(cash.absolute_worth)
			var/decl/currency/cur = GET_DECL(currency)
			to_chat(user, SPAN_NOTICE("You add [cash.get_worth()] [cur.name] to the pile."))
			to_chat(user, SPAN_NOTICE("It holds [get_worth()] [cur.name] now."))
			qdel(used_item)
		return TRUE
	else if(istype(used_item, /obj/item/gun/launcher/money))
		var/obj/item/gun/launcher/money/L = used_item
		L.absorb_cash(src, user)
		return TRUE
	return ..()

/obj/item/cash/on_update_icon()
	. = ..()
	icon_state = ""
	var/draw_worth = get_worth()
	var/decl/currency/cur = GET_DECL(currency)
	var/i = 0
	for(var/datum/denomination/denomination in cur.denominations)
		while(draw_worth >= denomination.marked_value)
			draw_worth -= denomination.marked_value
			var/image/banknote = new
			banknote.appearance = denomination.overlay
			banknote.plane = FLOAT_PLANE
			banknote.layer = FLOAT_LAYER
			var/matrix/M = matrix()
			M.Translate(rand(-6, 6), rand(-4, 8))
			if(denomination.rotate_icon)
				M.Turn(pick(-45, -27.5, 0, 0, 0, 0, 0, 0, 0, 27.5, 45))
			banknote.transform = M
			add_overlay(banknote)
			i++
			if(i >= overlay_cap)
				return

/obj/item/cash/proc/update_from_worth()
	var/decl/currency/cur = GET_DECL(currency)
	matter = list()
	matter[cur.material] = absolute_worth * max(1, round(SHEET_MATERIAL_AMOUNT/10))
	var/current_worth = get_worth()
	if(cur.denominations_by_value["[current_worth]"]) // Single piece.
		var/datum/denomination/denomination = cur.denominations_by_value["[current_worth]"]
		SetName(denomination.name)
		desc = "[initial(desc)] It's worth [current_worth] [current_worth == 1 ? cur.name_singular : cur.name]."
		w_class = ITEM_SIZE_TINY
	else
		SetName("pile of [cur.name]")
		desc = "[initial(desc)] It totals up to [current_worth] [current_worth == 1 ? cur.name_singular : cur.name]."
		w_class = ITEM_SIZE_SMALL
	update_icon()

/obj/item/cash/attack_self(var/mob/user)

	var/decl/currency/cur = GET_DECL(currency)
	var/current_worth = get_worth()

	// Handle coin flipping. Mostly copied from /obj/item/coin.
	var/datum/denomination/denomination = cur.denominations_by_value["[current_worth]"]
	if(denomination && length(denomination.faces) && (cur.denominations_by_value[length(cur.denominations_by_value)] == "[current_worth]" || alert("Do you wish to divide \the [src], or flip it?", "Flip or Split?", "Flip", "Split") == "Flip"))
		if(!can_flip)
			to_chat(user, SPAN_WARNING("\The [src] is already being flipped!"))
			return
		can_flip = FALSE
		playsound(user.loc, 'sound/effects/coin_flip.ogg', 75, 1)
		user.visible_message(SPAN_NOTICE("\The [user] flips \the [src] into the air."))
		sleep(1.5 SECOND)
		if(!QDELETED(user) && !QDELETED(src) && loc == user && get_worth() == current_worth)
			user.visible_message(SPAN_NOTICE("...and catches it, revealing that \the [src] landed on [pick(denomination.faces)]!"))
		can_flip = TRUE
		return TRUE
	// End coin flipping.

	if(QDELETED(src) || get_worth() <= 1 || user.incapacitated() || loc != user)
		return TRUE

	var/amount = input(user, "How many [cur.name] do you want to take? (0 to [get_worth() - 1])", "Take Money", 20) as num
	amount = round(clamp(amount, 0, floor(get_worth() - 1)))

	if(!amount || QDELETED(src) || get_worth() <= 1 || user.incapacitated() || loc != user)
		return TRUE

	amount = floor(amount * cur.absolute_value)
	adjust_worth(-(amount))
	var/obj/item/cash/cash = new(get_turf(src))
	cash.set_currency(currency)
	cash.adjust_worth(amount)
	user.put_in_hands(cash)

/obj/item/cash/c1
	absolute_worth = 1

/obj/item/cash/c10
	absolute_worth = 10

/obj/item/cash/c20
	absolute_worth = 20

/obj/item/cash/c50
	absolute_worth = 50

/obj/item/cash/c100
	absolute_worth = 100

/obj/item/cash/c200
	absolute_worth = 200
	w_class = ITEM_SIZE_SMALL // so that the money freezer doesn't overflow bc this is a pile instead of single bill

/obj/item/cash/c500
	absolute_worth = 500

/obj/item/cash/c1000
	absolute_worth = 1000

/obj/item/cash/scrip
	currency = /decl/currency/trader
	absolute_worth = 200


/obj/item/cash/scavbucks
	currency = /decl/currency/scav
	absolute_worth = 10

/obj/item/charge_stick
	name = "charge-stick"
	icon = 'icons/obj/items/credstick.dmi'
	icon_state = ICON_STATE_WORLD
	desc = "A digital stick that holds an amount of money."
	w_class = ITEM_SIZE_TINY
	material = /decl/material/solid/organic/plastic
	matter = list(/decl/material/solid/metal/copper = MATTER_AMOUNT_TRACE, /decl/material/solid/silicon = MATTER_AMOUNT_TRACE)
	var/max_worth = 5000
	var/loaded_worth = 0
	var/creator			// Who originally created this card. Mostly for book-keeping purposes. In game these cards are 'anonymous'.
	var/id = "" 		//So the ATM can set it so the EFTPOS can put a valid name on transactions.
	var/currency
	var/lock_type = /datum/extension/lockable/charge_stick
	var/grade = "peasant"

/obj/item/charge_stick/Initialize(ml, material_key)
	. = ..()
	id = "[grade]-card-[sequential_id("charge_stick")]"
	if(!ispath(currency, /decl/currency))
		currency = global.using_map.default_currency
		update_name_desc()
	set_extension(src, lock_type)

	if(grade && grade != "peasant")
		var/image/I = image(icon, "[icon_state]-[grade]")
		I.appearance_flags |= RESET_COLOR
		add_overlay(I, TRUE)
	update_icon()

/obj/item/charge_stick/proc/update_name_desc()
	if(!isnull(currency))
		var/decl/currency/cur = GET_DECL(currency)
		name = "[cur.name]-stick"
		desc = "A pre-charged digital stick that anonymously holds an amount of [cur.name]."
		return
	name = initial(name)
	desc = initial(desc)

/obj/item/charge_stick/proc/adjust_worth(amt)
	loaded_worth += amt
	if(loaded_worth < 0)
		loaded_worth = 0
	update_icon()

/obj/item/charge_stick/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..(user)
	if(distance <= 2 || user == loc)
		var/datum/extension/lockable/lock = get_extension(src, /datum/extension/lockable)
		if(lock.locked)
			. += SPAN_WARNING("\The [src] is locked.")
		else
			var/decl/currency/cur = GET_DECL(currency)
			. += SPAN_NOTICE("<b>Id:</b> [id].")
			. += SPAN_NOTICE("<b>[capitalize(cur.name)]</b> remaining: [floor(loaded_worth / cur.absolute_value)].")

/obj/item/charge_stick/get_base_value()
	. = holographic ? 0 : loaded_worth

/obj/item/charge_stick/attackby(var/obj/item/used_item, var/mob/user)
	var/datum/extension/lockable/lock = get_extension(src, /datum/extension/lockable)

	if(istype(used_item, /obj/item/charge_stick))
		var/obj/item/charge_stick/sender = used_item
		var/datum/extension/lockable/W_lock = get_extension(used_item, /datum/extension/lockable)
		if(lock.locked)
			to_chat(user, SPAN_WARNING("Cannot transfer funds to a locked [src]."))
			return TRUE
		if(W_lock.locked)
			to_chat(user, SPAN_WARNING("Cannot transfer funds from a locked [used_item]."))
			return TRUE
		if(sender.currency != currency)
			to_chat(user, SPAN_WARNING("[html_icon(src)] [src] chirps, \"Mismatched currency detected. Unable to transfer.\""))
			return TRUE
		var/amount = input(user, "How much of [sender.loaded_worth] do you want to transfer?", "[sender] transfer", "0") as null|num
		if(!amount)
			return TRUE
		if(amount < 0 || amount > sender.loaded_worth)
			to_chat(user, SPAN_NOTICE("[html_icon(src)] [src] chirps, \"Enter a valid number between 1 and [sender.loaded_worth] to transfer.\""))
			return TRUE
		sender.loaded_worth -= amount
		loaded_worth += amount
		sender.update_icon()
		update_icon()
		var/decl/currency/cur = GET_DECL(currency)
		to_chat(user, SPAN_NOTICE("[html_icon(src)] [src] chirps, \"Completed transfer of [amount] [cur.name].\""))
		return TRUE

	if(lock.attackby(used_item, user))
		return TRUE
	return ..()

/obj/item/charge_stick/emag_act(var/remaining_charges, var/mob/user, var/feedback)
	var/datum/extension/lockable/lock = get_extension(src, /datum/extension/lockable)
	if(lock.emagged)
		return FALSE
	.= lock.emag_act(remaining_charges, user, feedback)

/obj/item/charge_stick/attack_self(var/mob/user)
	var/datum/extension/lockable/lock = get_extension(src, /datum/extension/lockable)
	lock.ui_interact(user)

/obj/item/charge_stick/proc/is_locked()
	var/datum/extension/lockable/lock = get_extension(src, /datum/extension/lockable)
	return lock.locked

/**
	Given a number, returns a representation fit for a 3-digit display.

	Assumes that besides the digits themselves, display provides
	decimal point on the highest digit, plus (for overflow) and minus signs.
	Returns lists indexed by (power of ten)+1, that is, with [1] showing ones,
	[2] tens, [3] hundreds.
	Valid values are `-99` to `99<M>`, with `++<M>` and `---` for over and underflow,
	where <M> is the maximal provided decimal postfix (k, M, B, T, etc).
*/
/proc/number_to_3digits(value, var/list/postfixes = list("k", "M"))
	var/list/digits[3]
	var/lim = 1000
	if (value < 0)  // negatives
		digits[3] = "-"
		value *= -1
		lim = 100
	else
		for(var/s in postfixes)
			if (value < lim)
				break
			value /= 1000
			digits[1] = s
			lim = 100
	if (value >= lim) // over/underflow
		if (!digits[3])
			digits[3] = "+"
		if (!digits[1])
			digits[1] = digits[3]
		digits[2] = digits[3]
	else
		if ((lim == 100) && !digits[3]) // suffix on
			if (value < 1) // .
				digits[3] = "."
				value *= 100 // .X => 0X0
			else // just suffix
				value *= 10  // XX => XX0
		if (!digits[1])
			digits[1] = value % 10
		digits[2] = (value / 10) % 10
		if (!digits[3])
			digits[3] = (value / 100) % 10
	return digits

/obj/item/charge_stick/on_update_icon()
	. = ..()

	if(get_world_inventory_state() == ICON_STATE_WORLD)
		return

	var/datum/extension/lockable/lock = get_extension(src, /datum/extension/lockable)
	if(lock.locked)
		return

	var/decl/currency/cur = GET_DECL(currency)
	var/displayed_worth = loaded_worth / cur.absolute_value // Denominated in stick currency
	var/list/digits = number_to_3digits(displayed_worth)
	add_overlay("__[digits[1]]")
	add_overlay("_[digits[2]]_")
	add_overlay("[digits[3]]__")


/obj/item/charge_stick/copper
	grade = "copper"
	max_worth = 20000
	lock_type = /datum/extension/lockable/charge_stick/copper

/obj/item/charge_stick/silver
	grade = "silver"
	max_worth = 50000
	lock_type = /datum/extension/lockable/charge_stick/silver

/obj/item/charge_stick/gold
	grade = "gold"
	max_worth = 200000
	lock_type = /datum/extension/lockable/charge_stick/gold

/obj/item/charge_stick/platinum
	grade = "platinum"
	max_worth = 500000
	lock_type = /datum/extension/lockable/charge_stick/platinum

/atom/movable/proc/GetChargeStick()
	return null

/obj/item/charge_stick/GetChargeStick()
	return src
