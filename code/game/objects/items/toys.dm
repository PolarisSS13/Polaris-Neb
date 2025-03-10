/* Toys!
 * Contains:
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy gun
 *		Toy crossbow
 *		Toy swords
 *		Toy bosun's whistle
 *      Toy mechs
 *		Snap pops
 *		Water flower
 *      Therapy dolls
 *      Inflatable duck
 *		Action figures
 *		Plushies
 *		Toy cult sword
 *		Marshalling wand
 *		Ring bell
 *
 *	desk toys
 */



/obj/item/toy
	icon = 'icons/obj/toy/toy.dmi'
	throw_speed = 4
	throw_range = 20
	material = /decl/material/solid/organic/plastic
	_base_attack_force = 1

/*
 * Balloons
 */
/obj/item/chems/water_balloon
	name                          = "water balloon"
	desc                          = "A translucent balloon."
	icon                          = 'icons/obj/water_balloon.dmi'
	icon_state                    = ICON_STATE_WORLD
	w_class                       = ITEM_SIZE_TINY
	item_flags                    = ITEM_FLAG_NO_BLUDGEON
	obj_flags                     = OBJ_FLAG_HOLLOW
	atom_flags                    = ATOM_FLAG_OPEN_CONTAINER
	hitsound                      = 'sound/weapons/throwtap.ogg'
	throw_speed                   = 4
	throw_range                   = 20
	possible_transfer_amounts     = null
	amount_per_transfer_from_this = 10
	volume                        = 10
	material                      = /decl/material/solid/organic/plastic
	_base_attack_force            = 0

/obj/item/chems/water_balloon/adjust_mob_overlay(mob/living/user_mob, bodytype, image/overlay, slot, bodypart, use_fallback_if_icon_missing = TRUE)
	if(overlay && reagents?.total_volume <= 0)
		overlay.icon_state = "[overlay.icon_state]_empty"
	. = ..()

/obj/item/chems/water_balloon/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(distance <= 1)
		. += "It's [reagents?.total_volume > 0? "filled with liquid sloshing around" : "empty"]."

/obj/item/chems/water_balloon/on_reagent_change()
	if(!(. = ..()))
		return
	w_class = (reagents?.total_volume > 0)? ITEM_SIZE_SMALL : ITEM_SIZE_TINY
	//#TODO: Maybe acids should handle eating their own containers themselves?
	for(var/decl/material/reagent as anything in reagents?.reagent_volumes)
		if(reagent.solvent_power >= MAT_SOLVENT_STRONG)
			visible_message(SPAN_DANGER("\The [reagent] chews through \the [src]!"))
			physically_destroyed()

/obj/item/chems/water_balloon/throw_impact(atom/hit_atom, datum/thrownthing/TT)
	..()
	if(reagents?.total_volume > 0)
		visible_message(SPAN_WARNING("\The [src] bursts!"))
		physically_destroyed()

/obj/item/chems/water_balloon/physically_destroyed(skip_qdel)
	if(reagents?.total_volume > 0)
		new /obj/effect/temporary(src, 5, icon, "[get_world_inventory_state()]_burst")
		reagents.splash_turf(get_turf(src), reagents.total_volume)
		playsound(src, 'sound/effects/balloon-pop.ogg', 75, TRUE, 3)
	. = ..()

/obj/item/chems/water_balloon/on_update_icon()
	. = ..()
	icon_state = get_world_inventory_state()
	if(reagents?.total_volume <= 0)
		icon_state = "[icon_state]_empty"

/obj/item/chems/water_balloon/afterattack(obj/target, mob/user, proximity)
	if(!ATOM_IS_OPEN_CONTAINER(src) || !proximity)
		return
	if(standard_dispenser_refill(user, target))
		return TRUE
	if(standard_pour_into(user, target))
		return TRUE
	. = ..()

/obj/item/chems/water_balloon/get_alt_interactions(mob/user)
	. = ..()
	LAZYREMOVE(., /decl/interaction_handler/set_transfer/chems)

/obj/item/toy/balloon
	name = "\improper 'criminal' balloon"
	desc = "FUK CAPITALISM!11!"
	throw_speed = 4
	throw_range = 20
	icon = 'icons/obj/items/balloon.dmi'
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = ITEM_SIZE_HUGE
	_base_attack_force = 0

/obj/item/toy/balloon/Initialize()
	. = ..()
	desc = "Across the balloon is printed: \"[desc]\""

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/items/device/radio/beacon.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "gravitational singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/*
 * Toy swords
 */
/obj/item/energy_blade/sword/toy
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	sharp = FALSE
	edge = FALSE
	attack_verb = list("hit")
	material = /decl/material/solid/organic/plastic
	active_hitsound = 'sound/weapons/genhit.ogg'
	active_descriptor = "extended"
	active_attack_verb = list("hit")
	active_edge = FALSE
	active_sharp = FALSE
	_active_base_attack_force = 1
	_base_attack_force = 1

/obj/item/sword/katana/toy
	name = "toy katana"
	desc = "Woefully underpowered in D20."
	material = /decl/material/solid/organic/plastic

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy/toy.dmi'
	icon_state = "snappop"
	w_class = ITEM_SIZE_TINY

/obj/item/toy/snappop/throw_impact(atom/hit_atom)
	..()
	spark_at(src, cardinal_only = TRUE)
	new /obj/effect/decal/cleanable/ash(src.loc)
	visible_message(SPAN_WARNING("\The [src] explodes!"),SPAN_WARNING("You hear a snap!"))
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/obj/item/toy/snappop/Crossed(atom/movable/AM)
	//i guess carp and shit shouldn't set them off
	var/mob/living/M = AM
	if(!istype(M) || MOVING_DELIBERATELY(M))
		return
	to_chat(M, SPAN_WARNING("You step on the snap pop!"))
	spark_at(src, amount=2)
	new /obj/effect/decal/cleanable/ash(src.loc)
	visible_message(
		SPAN_WARNING("\The [src] explodes!"),
		SPAN_WARNING("You hear a snap!"))
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/*
 * Bosun's whistle
 */

/obj/item/toy/bosunwhistle
	name = "bosun's whistle"
	desc = "A genuine Admiral Krush Bosun's Whistle, for the aspiring ship's captain! Suitable for ages 8 and up, do not swallow."
	icon = 'icons/obj/toy/toy.dmi'
	icon_state = "bosunwhistle"
	var/cooldown = 0
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS

/obj/item/toy/bosunwhistle/attack_self(mob/user)
	if(cooldown < world.time - 35)
		to_chat(user, "<span class='notice'>You blow on [src], creating an ear-splitting noise!</span>")
		playsound(user, 'sound/misc/boatswain.ogg', 20, 1)
		cooldown = world.time

/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy/toy.dmi'
	icon_state = "ripleytoy"
	var/cooldown = 0
	w_class = ITEM_SIZE_SMALL

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user)
	if(cooldown < world.time - 8)
		to_chat(user, SPAN_NOTICE("You play with \the [src]."))
		playsound(user, 'sound/mecha/mechstep.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user)
	if(loc != user || cooldown >= world.time - 8)
		return ..()
	to_chat(user, SPAN_NOTICE("You play with \the [src]."))
	playsound(user, 'sound/mecha/mechturn.ogg', 20, 1)
	cooldown = world.time
	return TRUE

/obj/item/toy/prize/powerloader
	name = "toy ripley"
	desc = "Mini-mech action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-mech action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-mech action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-mech action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"

/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-mech action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-mech action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-mech action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-mech action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-mech action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-mech action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-mech action figure! Collect them all! 11/11."
	icon_state = "phazonprize"

/*
 * Action figures
 */

/obj/item/toy/figure
	name = "Completely Glitched action figure"
	desc = "A \"Space Life\" brand... wait, what the hell is this thing? It seems to be requesting the sweet release of death."
	icon_state = "assistant"
	icon = 'icons/obj/toy/toy.dmi'
	w_class = ITEM_SIZE_SMALL

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	desc = "A \"Space Life\" brand Chief Medical Officer action figure."
	icon_state = "cmo"

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	desc = "A \"Space Life\" brand Assistant action figure."
	icon_state = "assistant"

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	desc = "A \"Space Life\" brand Atmospheric Technician action figure."
	icon_state = "atmos"

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	desc = "A \"Space Life\" brand Bartender action figure."
	icon_state = "bartender"

/obj/item/toy/figure/borg
	name = "Cyborg action figure"
	desc = "A \"Space Life\" brand Cyborg action figure."
	icon_state = "borg"

/obj/item/toy/figure/gardener
	name = "Gardener action figure"
	desc = "A \"Space Life\" brand Gardener action figure."
	icon_state = "botanist"

/obj/item/toy/figure/captain
	name = "Captain action figure"
	desc = "A \"Space Life\" brand Captain action figure."
	icon_state = "captain"

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	desc = "A \"Space Life\" brand Cargo Technician action figure."
	icon_state = "cargotech"

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	desc = "A \"Space Life\" brand Chief Engineer action figure."
	icon_state = "ce"

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	desc = "A \"Space Life\" brand Chaplain action figure."
	icon_state = "chaplain"

/obj/item/toy/figure/chef
	name = "Chef action figure"
	desc = "A \"Space Life\" brand Chef action figure."
	icon_state = "chef"

/obj/item/toy/figure/chemist
	name = "Pharmacist action figure"
	desc = "A \"Space Life\" brand Pharmacist action figure."
	icon_state = "chemist"

/obj/item/toy/figure/clown
	name = "Clown action figure"
	desc = "A \"Space Life\" brand Clown action figure."
	icon_state = "clown"

/obj/item/toy/figure/corgi
	name = "Corgi action figure"
	desc = "A \"Space Life\" brand Corgi action figure."
	icon_state = "ian"

/obj/item/toy/figure/detective
	name = "Detective action figure"
	desc = "A \"Space Life\" brand Detective action figure."
	icon_state = "detective"

/obj/item/toy/figure/dsquad
	name = "Space Commando action figure"
	desc = "A \"Space Life\" brand Space Commando action figure."
	icon_state = "dsquad"

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	desc = "A \"Space Life\" brand Engineer action figure."
	icon_state = "engineer"

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	desc = "A \"Space Life\" brand Geneticist action figure, which was recently discontinued."
	icon_state = "geneticist"

/obj/item/toy/figure/hop
	name = "Head of Personnel action figure"
	desc = "A \"Space Life\" brand Head of Personnel action figure."
	icon_state = "hop"

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	desc = "A \"Space Life\" brand Head of Security action figure."
	icon_state = "hos"

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	desc = "A \"Space Life\" brand Quartermaster action figure."
	icon_state = "qm"

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	desc = "A \"Space Life\" brand Janitor action figure."
	icon_state = "janitor"

/obj/item/toy/figure/agent
	name = "Internal Affairs Agent action figure"
	desc = "A \"Space Life\" brand Internal Affairs Agent action figure."
	icon_state = "agent"

/obj/item/toy/figure/librarian
	name = "Librarian action figure"
	desc = "A \"Space Life\" brand Librarian action figure."
	icon_state = "librarian"

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	desc = "A \"Space Life\" brand Medical Doctor action figure."
	icon_state = "md"

/obj/item/toy/figure/mime
	name = "Mime action figure"
	desc = "A \"Space Life\" brand Mime action figure."
	icon_state = "mime"

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	desc = "A \"Space Life\" brand Shaft Miner action figure."
	icon_state = "miner"

/obj/item/toy/figure/ninja
	name = "Space Ninja action figure"
	desc = "A \"Space Life\" brand Space Ninja action figure."
	icon_state = "ninja"

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	desc = "A \"Space Life\" brand Wizard action figure."
	icon_state = "wizard"

/obj/item/toy/figure/rd
	name = "Chief Science Officer action figure"
	desc = "A \"Space Life\" brand Chief Science Officer action figure."
	icon_state = "rd"

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	desc = "A \"Space Life\" brand Roboticist action figure."
	icon_state = "roboticist"

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	desc = "A \"Space Life\" brand Scientist action figure."
	icon_state = "scientist"

/obj/item/toy/figure/syndie
	name = "Doom Operative action figure"
	desc = "A \"Space Life\" brand Doom Operative action figure."
	icon_state = "syndie"

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	desc = "A \"Space Life\" brand Security Officer action figure."
	icon_state = "secofficer"

/obj/item/toy/figure/warden
	name = "Warden action figure"
	desc = "A \"Space Life\" brand Warden action figure."
	icon_state = "warden"

/obj/item/toy/figure/psychologist
	name = "Psychologist action figure"
	desc = "A \"Space Life\" brand Psychologist action figure."
	icon_state = "psychologist"

/obj/item/toy/figure/paramedic
	name = "Paramedic action figure"
	desc = "A \"Space Life\" brand Paramedic action figure."
	icon_state = "paramedic"

/obj/item/toy/figure/ert
	name = "Emergency Response Team Commander action figure"
	desc = "A \"Space Life\" brand Emergency Response Team Commander action figure."
	icon_state = "ert"

//Toy cult sword
/obj/item/sword/cult_toy
	name = "foam sword"
	desc = "An arcane weapon (made of foam) wielded by the followers of the hit Saturday morning cartoon \"King Nursee and the Acolytes of Heroism\"."
	icon = 'icons/obj/items/weapon/swords/cult.dmi'
	material = /decl/material/solid/organic/plastic/foam
	edge = FALSE
	sharp = FALSE

/obj/item/inflatable_duck //#TODO: Move under obj/item/toy ?
	name = "inflatable duck"
	desc = "No bother to sink or swim when you can just float!"
	icon = 'icons/clothing/belt/inflatable.dmi'
	icon_state = ICON_STATE_WORLD
	slot_flags = SLOT_LOWER_BODY
	material = /decl/material/solid/organic/plastic

/obj/item/marshalling_wand //#TODO: Move under obj/item/toy ?
	name = "marshalling wand"
	desc = "An illuminated, hand-held baton used by hangar personnel to visually signal shuttle pilots. The signal changes depending on your intent."
	icon_state = "marshallingwand"
	item_state = "marshallingwand"
	icon = 'icons/obj/toy/toy.dmi'
	slot_flags = SLOT_LOWER_BODY
	w_class = ITEM_SIZE_SMALL
	_base_attack_force = 1
	attack_verb = list("attacked", "whacked", "jabbed", "poked", "marshalled")
	material = /decl/material/solid/organic/plastic

/obj/item/marshalling_wand/Initialize()
	set_light(1.5, 1.5, "#ff0000")
	return ..()

/obj/item/marshalling_wand/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/rustle1.ogg', 100, 1)
	if (user.check_intent(I_FLAG_HELP))
		user.visible_message("<span class='notice'>[user] beckons with \the [src], signalling forward motion.</span>",
							"<span class='notice'>You beckon with \the [src], signalling forward motion.</span>")
	else if (user.check_intent(I_FLAG_DISARM))
		user.visible_message("<span class='notice'>[user] holds \the [src] above their head, signalling a stop.</span>",
							"<span class='notice'>You hold \the [src] above your head, signalling a stop.</span>")
	else if (user.check_intent(I_FLAG_GRAB))
		var/wand_dir
		if(user.get_equipped_item(BP_L_HAND) == src)
			wand_dir = "left"
		else if (user.get_equipped_item(BP_R_HAND) == src)
			wand_dir = "right"
		else
			wand_dir = pick("left", "right")
		user.visible_message("<span class='notice'>[user] waves \the [src] to the [wand_dir], signalling a turn.</span>",
							"<span class='notice'>You wave \the [src] to the [wand_dir], signalling a turn.</span>")
	else if (user.check_intent(I_FLAG_HARM))
		user.visible_message("<span class='warning'>[user] frantically waves \the [src] above their head!</span>",
							"<span class='warning'>You frantically wave \the [src] above your head!</span>")

/obj/item/toy/shipmodel
	name = "table-top spaceship model"
	desc = "This is a 1:250th scale spaceship model on a handsome wooden stand. Small lights blink on the hull and at the engine exhaust."
	icon = 'icons/obj/toy/toy.dmi'
	icon_state = "shipmodel"

/obj/item/toy/ringbell
	name = "ringside bell"
	desc = "A bell used to signal the beginning and end of various ring sports."
	icon = 'icons/obj/toy/toy.dmi'
	icon_state= "ringbell"
	anchored = TRUE

/obj/item/toy/ringbell/attack_hand(mob/user)
	if(!user.check_dexterity(DEXTERITY_SIMPLE_MACHINES, TRUE))
		return ..()
	if (user.check_intent(I_FLAG_HELP))
		user.visible_message("<span class='notice'>[user] rings \the [src], signalling the beginning of the contest.</span>")
		playsound(user.loc, 'sound/items/oneding.ogg', 60)
	else if (user.check_intent(I_FLAG_DISARM))
		user.visible_message("<span class='notice'>[user] rings \the [src] three times, signalling the end of the contest!</span>")
		playsound(user.loc, 'sound/items/threedings.ogg', 60)
	else if (user.check_intent(I_FLAG_HARM))
		user.visible_message("<span class='warning'>[user] rings \the [src] repeatedly, signalling a disqualification!</span>")
		playsound(user.loc, 'sound/items/manydings.ogg', 60)
	return TRUE

//Office Desk Toys

/obj/item/toy/desk
	abstract_type = /obj/item/toy/desk
	var/on = 0
	var/activation_sound = 'sound/effects/flashlight.ogg'

/obj/item/toy/desk/on_update_icon()
	. = ..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/toy/desk/attack_self(mob/user)
	on = !on
	if(on && activation_sound)
		playsound(src.loc, activation_sound, 75, 1)
	update_icon()
	return 1

/obj/item/toy/desk/newtoncradle
	name = "\improper Newton's cradle"
	desc = "An ancient 21st century super-weapon model demonstrating that Sir Isaac Newton is the deadliest sonuvabitch in space."
	icon_state = "newtoncradle"

/obj/item/toy/desk/fan
	name = "office fan"
	desc = "Your greatest fan."
	icon_state= "fan"

/obj/item/toy/desk/officetoy
	name = "office toy"
	desc = "A generic microfusion powered office desk toy. Only generates magnetism and ennui."
	icon_state= "desktoy"

/obj/item/toy/desk/dippingbird
	name = "dipping bird toy"
	desc = "An ancient human bird idol, worshipped by clerks and desk jockeys."
	icon_state= "dippybird"

// tg station ports

/obj/item/toy/eightball
	name = "magic eightball"
	desc = "A black ball with a stencilled number eight in white on the side. It seems full of dark liquid.\nThe instructions state that you should ask your question aloud, and then shake."
	icon_state = "eightball"
	w_class = ITEM_SIZE_SMALL

	var/static/list/possible_answers = list(
		"It is certain",
		"It is decidedly so",
		"Without a doubt",
		"Yes, definitely",
		"You may rely on it",
		"As I see it, yes",
		"Most likely",
		"Outlook good",
		"Yes",
		"Signs point to yes",
		"Reply hazy, try again",
		"Ask again later",
		"Better not tell you now",
		"Cannot predict now",
		"Concentrate and ask again",
		"Don't count on it",
		"My reply is no",
		"My sources say no",
		"Outlook not so good",
		"Very doubtful")

/obj/item/toy/eightball/attack_self(mob/user)
	user.visible_message("<span class='notice'>\The [user] shakes \the [src] for a moment, and it says, \"[pick(possible_answers) ].\"</span>")

/obj/item/toy/eightball/afterattack(obj/O, mob/user, var/proximity)
	. = ..()
	if (proximity)
		visible_message("<span class='warning'>\The [src] says, \"[pick(possible_answers) ]\" as it hits \the [O]!</span>")


//////////////////////////////////////////////////////
//					Chess Pieces					//
//////////////////////////////////////////////////////

/obj/item/toy/chess
	name = "oversized chess piece"
	desc = "This should never display."
	icon = 'icons/obj/items/chess.dmi'
	w_class = ITEM_SIZE_LARGE
	drop_sound = 'sound/foley/glass.ogg'
	color = COLOR_OFF_WHITE
	abstract_type = /obj/item/toy/chess
	// Some offsets so they start nicely center-ish on the turf.
	randpixel = 0
	pixel_y = 6
	pixel_x = 0
	_base_attack_force = 1
	var/rule_info

/obj/item/toy/chess/get_examine_strings(mob/user, distance, infix, suffix)
	. = ..()
	if(rule_info)
		. += SPAN_NOTICE(rule_info)

/obj/item/toy/chess/pawn
	name = "oversized white pawn"
	desc = "A large pawn piece for playing chess. It's made of white enamel."
	rule_info = "Pawns can move forward one square, if that square is unoccupied. If the pawn has not yet moved, it has the option of moving two squares forward provided both squares in front of the pawn are unoccupied. A pawn cannot move backward. They can only capture an enemy piece on either of the two tiles diagonally in front of them, but not the tile directly in front of them."
	icon_state = "pawn"

/obj/item/toy/chess/pawn/black
	name = "oversized black pawn"
	desc = "A large pawn piece for playing chess. It's made of black enamel."
	color = COLOR_GRAY40

/obj/item/toy/chess/rook
	name = "oversized white rook"
	desc = "A large rook piece for playing chess. It's made of white enamel."
	rule_info = "The Rook can move any number of vacant squares vertically or horizontally."
	icon_state = "rook"

/obj/item/toy/chess/rook/black
	name = "oversized black rook"
	desc = "A large rook piece for playing chess. It's made of black enamel."
	color = COLOR_GRAY40

/obj/item/toy/chess/knight
	name = "oversized white knight"
	desc = "A large knight piece for playing chess. It's made of white enamel. Sadly, you can't ride it."
	rule_info = "The Knight can either move two squares horizontally and one square vertically or two squares vertically and one square horizontally. The knight's movement can also be viewed as an 'L' laid out at any horizontal or vertical angle."
	icon_state = "knight"

/obj/item/toy/chess/knight/black
	name = "oversized black knight"
	desc = "A large knight piece for playing chess. It's made of black enamel. 'Just a flesh wound.'"
	color = COLOR_GRAY40

/obj/item/toy/chess/bishop
	name = "oversized white bishop"
	desc = "A large bishop piece for playing chess. It's made of white enamel."
	rule_info = "The Bishop can move any number of vacant squares in any diagonal direction."
	icon_state = "bishop"

/obj/item/toy/chess/bishop/black
	name = "oversized black bishop"
	desc = "A large bishop piece for playing chess. It's made of black enamel."
	color = COLOR_GRAY40

/obj/item/toy/chess/queen
	name = "oversized white queen"
	desc = "A large queen piece for playing chess. It's made of white enamel."
	rule_info = "The Queen can move any number of vacant squares diagonally, horizontally, or vertically."
	icon_state = "queen"

/obj/item/toy/chess/queen/black
	name = "oversized black queen"
	desc = "A large queen piece for playing chess. It's made of black enamel."
	color = COLOR_GRAY40

/obj/item/toy/chess/king
	name = "oversized white king"
	desc = "A large king piece for playing chess. It's made of white enamel."
	rule_info = "The King can move exactly one square horizontally, vertically, or diagonally. If your opponent captures this piece, you lose."
	icon_state = "king"

/obj/item/toy/chess/king/black
	name = "oversized black king"
	desc = "A large king piece for playing chess. It's made of black enamel."
	color = COLOR_GRAY40
