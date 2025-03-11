/obj/item/clothing/jumpsuit/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon = 'icons/clothing/jumpsuits/jumpsuit_mailman.dmi'

/obj/item/clothing/jumpsuit/rainbow
	name = "rainbow"
	icon = 'icons/clothing/jumpsuits/jumpsuit_rainbow.dmi'

/obj/item/clothing/jumpsuit/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon = 'icons/clothing/jumpsuits/jumpsuit_psychadelic.dmi'

/obj/item/clothing/jumpsuit/psyche/get_assumed_clothing_state_modifiers()
	return null

/obj/item/clothing/jumpsuit/wetsuit
	name = "tactical wetsuit"
	desc = "For when you want to scuba dive your way into an enemy base but still want to show off a little skin."
	icon = 'icons/clothing/jumpsuits/wetsuit.dmi'
	body_parts_covered = SLOT_UPPER_BODY|SLOT_LOWER_BODY

/obj/item/clothing/jumpsuit/psysuit
	name = "dark undersuit"
	desc = "A thick, layered grey undersuit lined with power cables. Feels a little like wearing an electrical storm."
	icon = 'icons/clothing/jumpsuits/jumpsuit_psionic.dmi'
	body_parts_covered = SLOT_UPPER_BODY|SLOT_LOWER_BODY|SLOT_LEGS|SLOT_FEET|SLOT_ARMS|SLOT_HANDS

/obj/item/clothing/jumpsuit/caretaker
	name = "caretaker's jumpsuit"
	desc = "A holy jumpsuit. Treat it well."
	icon = 'icons/clothing/jumpsuits/caretaker.dmi'
	bodytype_equip_flags = BODY_EQUIP_FLAG_HUMANOID
