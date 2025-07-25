/decl/emote/visible
	abstract_type = /decl/emote/visible
	message_type = VISIBLE_MESSAGE

/decl/emote/visible/scratch
	key = "scratch"
	check_restraints = TRUE
	emote_message_3p = "$USER$ scratches."

/decl/emote/visible/drool
	key = "drool"
	emote_message_3p = "$USER$ drools."
	conscious = 0

/decl/emote/visible/nod
	key = "nod"
	emote_message_3p_target = "$USER$ nods $USER_THEIR$ head at $TARGET$."
	emote_message_3p = "$USER$ nods $USER_THEIR$ head."

/decl/emote/visible/sway
	key = "sways"
	emote_message_3p = "$USER$ sways around dizzily."

/decl/emote/visible/sulk
	key = "sulk"
	emote_message_3p = "$USER$ sulks down sadly."

/decl/emote/visible/dance
	key = "dance"
	check_restraints = TRUE
	emote_message_3p = "$USER$ dances around happily."

/decl/emote/visible/roll
	key = "roll"
	check_restraints = TRUE
	emote_message_3p = "$USER$ rolls."

/decl/emote/visible/shake
	key = "shake"
	emote_message_3p = "$USER$ shakes $USER_THEIR$ head."

/decl/emote/visible/jump
	key = "jump"
	emote_message_3p = "$USER$ jumps!"

/decl/emote/visible/shiver
	key = "shiver"
	emote_message_3p = "$USER$ shivers."
	conscious = 0

/decl/emote/visible/collapse
	key = "collapse"
	emote_message_3p = "$USER$ collapses!"

/decl/emote/visible/collapse/do_extra(atom/user)
	if(ismob(user))
		var/mob/user_mob = user
		SET_STATUS_MAX(user_mob, STAT_PARA, 2)

/decl/emote/visible/flash
	key = "flash"
	emote_message_3p = "The lights on $USER$ flash quickly."

/decl/emote/visible/blink
	key = "blink"
	emote_message_3p = "$USER$ blinks."

/decl/emote/visible/airguitar
	key = "airguitar"
	check_restraints = TRUE
	emote_message_3p = "$USER$ is strumming the air and headbanging like a safari chimp."

/decl/emote/visible/blink_r
	key = "blink_r"
	emote_message_3p = "$USER$ blinks rapidly."

/decl/emote/visible/bow
	key = "bow"
	emote_message_3p_target = "$USER$ bows to $TARGET$."
	emote_message_3p = "$USER$ bows."

/decl/emote/visible/salute
	key = "salute"
	emote_message_3p_target = "$USER$ salutes $TARGET$."
	emote_message_3p = "$USER$ salutes."
	check_restraints = TRUE

/decl/emote/visible/flap
	key = "flap"
	check_restraints = TRUE
	emote_message_3p = "$USER$ flaps $USER_THEIR$ wings."

/decl/emote/visible/aflap
	key = "aflap"
	check_restraints = TRUE
	emote_message_3p = "$USER$ flaps $USER_THEIR$ wings ANGRILY!"

/decl/emote/visible/eyebrow
	key = "eyebrow"
	emote_message_3p = "$USER$ raises an eyebrow."

/decl/emote/visible/twitch
	key = "twitch"
	emote_message_3p = "$USER$ twitches."
	conscious = 0

/decl/emote/visible/twitch_v
	key = "twitch_v"
	emote_message_3p = "$USER$ twitches violently."
	conscious = 0

/decl/emote/visible/faint
	key = "faint"
	emote_message_3p = "$USER$ faints."

/decl/emote/visible/faint/do_extra(atom/user)
	var/mob/user_mob = user
	if(istype(user_mob) && !HAS_STATUS(user_mob, STAT_ASLEEP))
		SET_STATUS_MAX(user_mob, STAT_ASLEEP, 10)

/decl/emote/visible/frown
	key = "frown"
	emote_message_3p = "$USER$ frowns."

/decl/emote/visible/blush
	key = "blush"
	emote_message_3p = "$USER$ blushes."

/decl/emote/visible/wave
	key = "wave"
	emote_message_3p_target = "$USER$ waves at $TARGET$."
	emote_message_3p = "$USER$ waves."
	check_restraints = TRUE

/decl/emote/visible/glare
	key = "glare"
	emote_message_3p_target = "$USER$ glares at $TARGET$."
	emote_message_3p = "$USER$ glares."

/decl/emote/visible/stare
	key = "stare"
	emote_message_3p_target = "$USER$ stares at $TARGET$."
	emote_message_3p = "$USER$ stares."

/decl/emote/visible/look
	key = "look"
	emote_message_3p_target = "$USER$ looks at $TARGET$."
	emote_message_3p = "$USER$ looks."

/decl/emote/visible/point
	key = "point"
	check_restraints = TRUE
	emote_message_3p_target = "$USER$ points to $TARGET$."
	emote_message_3p = "$USER$ points."

/decl/emote/visible/raise
	key = "raise"
	check_restraints = TRUE
	emote_message_3p = "$USER$ raises a hand."

/decl/emote/visible/grin
	key = "grin"
	emote_message_3p_target = "$USER$ grins at $TARGET$."
	emote_message_3p = "$USER$ grins."

/decl/emote/visible/shrug
	key = "shrug"
	emote_message_3p = "$USER$ shrugs."

/decl/emote/visible/smile
	key = "smile"
	emote_message_3p_target = "$USER$ smiles at $TARGET$."
	emote_message_3p = "$USER$ smiles."

/decl/emote/visible/pale
	key = "pale"
	emote_message_3p = "$USER$ goes pale for a second."

/decl/emote/visible/tremble
	key = "tremble"
	emote_message_3p = "$USER$ trembles in fear!"

/decl/emote/visible/wink
	key = "wink"
	emote_message_3p_target = "$USER$ winks at $TARGET$."
	emote_message_3p = "$USER$ winks."

/decl/emote/visible/hug
	key = "hug"
	check_restraints = TRUE
	emote_message_3p_target = "$USER$ hugs $TARGET$."
	emote_message_3p = "$USER$ hugs $USER_SELF$."
	check_range = 1

/decl/emote/visible/dap
	key = "dap"
	check_restraints = TRUE
	emote_message_3p_target = "$USER$ gives daps to $TARGET$."
	emote_message_3p = "$USER$ sadly can't find anybody to give daps to, and daps $USER_SELF$."

/decl/emote/visible/bounce
	key = "bounce"
	emote_message_3p = "$USER$ bounces in place."

/decl/emote/visible/jiggle
	key = "jiggle"
	emote_message_3p = "$USER$ jiggles!"

/decl/emote/visible/lightup
	key = "light"
	emote_message_3p = "$USER$ lights up for a bit, then stops."

/decl/emote/visible/vibrate
	key = "vibrate"
	emote_message_3p = "$USER$ vibrates!"

/decl/emote/visible/deathgasp_robot
	key = "rdeathgasp"
	emote_message_3p = "$USER$ shudders violently for a moment, then becomes motionless, $USER_THEIR$ eyes slowly darkening."

/decl/emote/visible/handshake
	key = "handshake"
	check_restraints = TRUE
	emote_message_3p_target = "$USER$ shakes hands with $TARGET$."
	emote_message_3p = "$USER$ shakes hands with $USER_SELF$."
	check_range = 1

/decl/emote/visible/handshake/get_emote_message_3p(var/atom/user, var/atom/target, var/extra_params)
	if(target && !user.Adjacent(target))
		return "$USER$ holds out $USER_THEIR$ hand out to $TARGET$."
	return ..()

/decl/emote/visible/signal
	key = "signal"
	emote_message_3p_target = "$USER$ signals at $TARGET$."
	emote_message_3p = "$USER$ signals."
	check_restraints = TRUE

/decl/emote/visible/signal/get_emote_message_3p(var/mob/living/user, var/atom/target, var/extra_params)
	if(istype(user) && user.get_empty_hand_slot())
		var/t1 = round(text2num(extra_params))
		if(isnum(t1) && t1 <= 5)
			return "$USER$ raises [t1] finger\s."
	return .. ()

/decl/emote/visible/afold
	key = "afold"
	check_restraints = TRUE
	emote_message_3p = "$USER$ folds $USER_THEIR$ arms."

/decl/emote/visible/alook
	key = "alook"
	emote_message_3p = "$USER$ looks away."

/decl/emote/visible/hbow
	key = "hbow"
	emote_message_3p = "$USER$ bows $USER_THEIR$ head."

/decl/emote/visible/hip
	key = "hip"
	check_restraints = TRUE
	emote_message_3p = "$USER$ puts $USER_THEIR$ hands on $USER_THEIR$ hips."

/decl/emote/visible/holdup
	key = "holdup"
	check_restraints = TRUE
	emote_message_3p = "$USER$ holds up $USER_THEIR$ palms."

/decl/emote/visible/hshrug
	key = "hshrug"
	emote_message_3p = "$USER$ gives a half shrug."

/decl/emote/visible/crub
	key = "crub"
	check_restraints = TRUE
	emote_message_3p = "$USER$ rubs $USER_THEIR$ chin."

/decl/emote/visible/eroll
	key = "eroll"
	emote_message_3p = "$USER$ rolls $USER_THEIR$ eyes."
	emote_message_3p_target = "$USER$ rolls $USER_THEIR$ eyes at $TARGET$."

/decl/emote/visible/erub
	key = "erub"
	check_restraints = TRUE
	emote_message_3p = "$USER$ rubs $USER_THEIR$ eyes."

/decl/emote/visible/fslap
	key = "fslap"
	check_restraints = TRUE
	emote_message_3p = "$USER$ slaps $USER_THEIR$ forehead."

/decl/emote/visible/ftap
	key = "ftap"
	emote_message_3p = "$USER$ taps $USER_THEIR$ foot."

/decl/emote/visible/hrub
	key = "hrub"
	check_restraints = TRUE
	emote_message_3p = "$USER$ rubs $USER_THEIR$ hands together."

/decl/emote/visible/hspread
	key = "hspread"
	check_restraints = TRUE
	emote_message_3p = "$USER$ spreads $USER_THEIR$ hands."

/decl/emote/visible/pocket
	key = "pocket"
	check_restraints = TRUE
	emote_message_3p = "$USER$ shoves $USER_THEIR$ hands in $USER_THEIR$ pockets."

/decl/emote/visible/pocket/mob_can_use(mob/living/user, assume_available)
	. = ..()
	if(!.)
		return
	// You need a uniform to have pockets.
	var/datum/inventory_slot/check_slot = user.get_inventory_slot_datum(slot_w_uniform_str)
	if(!check_slot?.get_equipped_item())
		return FALSE

/decl/emote/visible/rsalute
	key = "rsalute"
	check_restraints = TRUE
	emote_message_3p = "$USER$ returns the salute."

/decl/emote/visible/rshoulder
	key = "rshoulder"
	emote_message_3p = "$USER$ rolls $USER_THEIR$ shoulders."

/decl/emote/visible/squint
	key = "squint"
	emote_message_3p = "$USER$ squints."
	emote_message_3p_target = "$USER$ squints at $TARGET$."

/decl/emote/visible/tfist
	key = "tfist"
	emote_message_3p = "$USER$ tightens $USER_THEIR$ hands into fists."

/decl/emote/visible/tilt
	key = "tilt"
	emote_message_3p = "$USER$ tilts $USER_THEIR$ head."

/decl/emote/visible/spin
	key = "spin"
	check_restraints = TRUE
	emote_message_3p = "$USER$ spins!"
	emote_delay = 2 SECONDS

/decl/emote/visible/spin/do_extra(atom/user)
	if(ismob(user))
		var/mob/user_mob = user
		user_mob.spin(emote_delay, 1)

/decl/emote/visible/sidestep
	key = "sidestep"
	check_restraints = TRUE
	emote_message_3p = "$USER$ steps rhythmically and moves side to side."
	emote_delay = 1.2 SECONDS

/decl/emote/visible/sidestep/do_extra(atom/user)
	animate(user, pixel_x = 5, time = 5)
	sleep(3)
	animate(user, pixel_x = -5, time = 5)
	animate(pixel_x = user.default_pixel_x, pixel_y = user.default_pixel_x, time = 2)

/decl/emote/visible/vomit
	key = "vomit"

/decl/emote/visible/vomit/mob_can_use(mob/living/user, assume_available = FALSE)
	. = ..() && user.check_has_mouth() && !user.isSynthetic()

/decl/emote/visible/vomit/do_emote(var/atom/user, var/extra_params)
	var/mob/living/human/H = user
	if(istype(H))
		H.vomit(deliberate = TRUE)
		return TRUE
	to_chat(src, SPAN_WARNING("You are unable to vomit."))
	return FALSE
