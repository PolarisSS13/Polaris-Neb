/decl/emote/audible/drake_roar
	key = "droar"
	emote_message_3p = "$USER$ inflates $USER_THEIR$ throat, lifts $USER_THEIR$ head up, and releases a resonating, bone-shaking roar."
	emote_sound = 'mods/species/drakes/sounds/drake_roar.ogg'
	broadcast_sound = 'mods/species/drakes/sounds/drake_roar.ogg'
	emote_cooldown = 20 SECONDS
	broadcast_distance = 90

/decl/emote/audible/drake_roar/broadcast_emote_to(send_sound, mob/target, var/origin_z, direction)
	. = ..()
	if (.)
		var/turf/T = get_turf(target)
		if(!T || T.z == origin_z)
			to_chat(target, SPAN_NOTICE("You hear a resonant bellowing roar from somewhere to the [dir2text(direction)]."))
		else if(T.z < origin_z)
			to_chat(target, SPAN_NOTICE("You hear a resonant bellowing roar from somewhere above you, to the [dir2text(direction)]."))
		else
			to_chat(target, SPAN_NOTICE("You hear a resonant bellowing roar from somewhere below you, to the [dir2text(direction)]."))

/decl/emote/audible/drake_warble
	key = "dwarble"
	emote_message_3p = "$USER$ warbles happily."

/decl/emote/audible/drake_purr
	key = "dpurr"
	emote_message_3p = "$USER$ emits a low, rumbling purr."
	emote_message_3p_target = "$USER$ emits a low, rumbling purr as $USER_THEY$ rub$USER_S$ $USER_THEIR$ head against $TARGET$."

// Do some bespoke adjacency checking since we want this to be more granular than a straight range check.
/decl/emote/audible/drake_purr/get_emote_message_3p(var/atom/user, var/atom/target, var/extra_params)
	. = ..()
	if(. == emote_message_3p_target && target && !user.Adjacent(target))
		. = "$USER$ half-lids their eyes at $TARGET$ and emits a low, rumbling purr."

/decl/emote/audible/drake_grumble
	key = "dgrumble"
	emote_message_3p = "$USER$ grumbles unhappily."
	emote_message_3p_target = "$USER$ grumbles unhappily at $TARGET$."
	emote_sound = 'mods/species/drakes/sounds/drake_grumble.ogg'

/decl/emote/audible/drake_huff
	key = "dhuff"
	emote_message_3p = "$USER$ huffs!"
	emote_message_3p_target = "$USER$ huffs at $TARGET$!"
	emote_sound = 'mods/species/drakes/sounds/drake_huff.ogg'

/decl/emote/audible/drake_warn
	key = "dwarn"
	emote_message_1p = "You fill your throat sacs with spittle, preparing to attack."
	emote_message_1p_target = "You stare at $TARGET$ as you fill your throat sacs with spittle, preparing to attack."
	emote_message_3p = "$USER$ works $USER_THEIR$ throat, making a horrible wet noise..."
	emote_message_3p_target = "$USER$ stares intently at $TARGET$, working $USER_THEIR$ throat to make a horrible wet noise..."
	emote_sound = 'mods/species/drakes/sounds/drake_warn.ogg'

/decl/emote/audible/drake_warn/hatchling
	key = "hwarn"
	emote_sound = 'mods/species/drakes/sounds/hatchling_warn.ogg'

/decl/emote/audible/drake_warn/Initialize()
	. = ..()
	emote_message_1p =        SPAN_WARNING(emote_message_1p)
	emote_message_1p_target = SPAN_WARNING(emote_message_1p_target)
	emote_message_3p =        SPAN_WARNING(emote_message_3p)
	emote_message_3p_target = SPAN_WARNING(emote_message_3p_target)

/decl/emote/audible/drake_rattle
	key = "drattle"
	emote_message_1p = "You bark a challenge and rattle your neck-spines threateningly."
	emote_message_1p_target = "You challenge $TARGET$ with a sharp bark, rattling your neck-spines threateningly."
	emote_message_3p = "$USER$ barks sharply and rattles $USER_THEIR$ neck-spines!"
	emote_message_3p_target = "$USER$ barks sharply at $TARGET$, rattling $USER_THEIR$ neck-spines!"
	emote_sound = 'mods/species/drakes/sounds/drake_rattle.ogg'

/decl/emote/audible/drake_rattle/Initialize()
	. = ..()
	emote_message_1p =        SPAN_WARNING(emote_message_1p)
	emote_message_1p_target = SPAN_WARNING(emote_message_1p_target)
	emote_message_3p =        SPAN_WARNING(emote_message_3p)
	emote_message_3p_target = SPAN_WARNING(emote_message_3p_target)

/decl/emote/visible/drake_headbutt
	key = "headbutt"
	emote_message_3p = "$USER$ waves $USER_THEIR$ head around energetically."
	emote_message_3p_target =  "$USER$ headbutts $TARGET$!"
	check_range = 1
	emote_cooldown = 5 SECONDS

/decl/emote/visible/drake_headbutt/finalize_target(var/mob/user, var/atom/target)
	return user.Adjacent(target) && ..()

/decl/emote/visible/drake_headbutt/do_extra(atom/user, atom/target)
	. = ..()

	if(!ismob(user))
		return

	// Copied from disarm.
	if(!isliving(target) || prob(75))
		return

	var/mob/living/victim = target
	if(!victim.can_slip())
		return

	var/mob/user_mob = user
	var/armor_check = 100 * victim.get_blocked_ratio(user_mob.get_target_zone(), BRUTE, damage = 20)
	if(armor_check < 100)
		victim.apply_effect(3, WEAKEN, armor_check)
	playsound(victim, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/decl/emote/audible/drake_rumble
	key = "drumble"
	emote_message_3p = "$USER$ rumbles in the depths of $USER_THEIR$ chest."
	emote_sound = 'mods/species/drakes/sounds/drake_rumble.ogg'

/decl/emote/audible/drake_hatchling_growl
	key = "hgrowl"
	emote_message_3p = "$USER$ voices a high-pitched growl!"
	emote_sound = 'mods/species/drakes/sounds/hatchling_growl.ogg'

/decl/emote/audible/drake_hatchling_whine
	key = "hwhine"
	emote_message_3p = "$USER$ whines plaintively!"
	emote_sound = 'mods/species/drakes/sounds/hatchling_whine.ogg'

/decl/emote/audible/drake_hatchling_yelp
	key = "hyelp"
	emote_message_3p = "$USER$ yelps!"
	emote_sound = 'mods/species/drakes/sounds/hatchling_yelp.ogg'

/decl/emote/audible/drake_sneeze
	key = "dsneeze"
	emote_message_1p = "You sneeze!"
	emote_message_3p = "$USER$ sneezes!"
	emote_sound = 'mods/species/drakes/sounds/drake_sneeze.ogg'
