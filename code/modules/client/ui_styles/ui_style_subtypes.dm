// Midnight just uses base type defaults since that's where they came from.
/decl/ui_style/midnight
	name = "Midnight"
	uid  = "ui_style_midnight"

/decl/ui_style/orange
	name = "Orange"
	uid  = "ui_style_orange"
	override_icons = list(
		(UI_ICON_ATTACK)      = 'icons/mob/screen/styles/orange/attack_selector.dmi',
		(UI_ICON_FIRE_INTENT) = 'icons/mob/screen/styles/orange/fire_intent.dmi',
		(UI_ICON_HANDS)       = 'icons/mob/screen/styles/orange/hands.dmi',
		(UI_ICON_INTERACTION) = 'icons/mob/screen/styles/orange/interaction.dmi',
		(UI_ICON_INVENTORY)   = 'icons/mob/screen/styles/orange/inventory.dmi',
		(UI_ICON_MOVEMENT)    = 'icons/mob/screen/styles/orange/movement.dmi',
		(UI_ICON_UP_HINT)     = 'icons/mob/screen/styles/orange/uphint.dmi',
		(UI_ICON_ZONE_SELECT) = 'icons/mob/screen/styles/orange/zone_selector.dmi'
	)

/decl/ui_style/old
	name = "Old"
	uid  = "ui_style_old"
	override_icons = list(
		(UI_ICON_ATTACK)      = 'icons/mob/screen/styles/old/attack_selector.dmi',
		(UI_ICON_FIRE_INTENT) = 'icons/mob/screen/styles/old/fire_intent.dmi',
		(UI_ICON_HANDS)       = 'icons/mob/screen/styles/old/hands.dmi',
		(UI_ICON_INTERACTION) = 'icons/mob/screen/styles/old/interaction.dmi',
		(UI_ICON_INVENTORY)   = 'icons/mob/screen/styles/old/inventory.dmi',
		(UI_ICON_MOVEMENT)    = 'icons/mob/screen/styles/old/movement.dmi',
		(UI_ICON_UP_HINT)     = 'icons/mob/screen/styles/old/uphint.dmi',
		(UI_ICON_ZONE_SELECT) = 'icons/mob/screen/styles/old/zone_selector.dmi'
	)

/decl/ui_style/old_noborder
	name = "Old (no border)"
	uid  = "ui_style_old_noborder"
	override_icons = list(
		(UI_ICON_ATTACK)      = 'icons/mob/screen/styles/old/attack_selector.dmi',
		(UI_ICON_FIRE_INTENT) = 'icons/mob/screen/styles/old/fire_intent.dmi',
		(UI_ICON_HANDS)       = 'icons/mob/screen/styles/old/hands.dmi',
		(UI_ICON_INTERACTION) = 'icons/mob/screen/styles/old/interaction.dmi',
		(UI_ICON_INVENTORY)   = 'icons/mob/screen/styles/old_noborder/inventory.dmi',
		(UI_ICON_MOVEMENT)    = 'icons/mob/screen/styles/old/movement.dmi',
		(UI_ICON_UP_HINT)     = 'icons/mob/screen/styles/old_noborder/uphint.dmi',
		(UI_ICON_ZONE_SELECT) = 'icons/mob/screen/styles/old_noborder/zone_selector.dmi'
	)

/decl/ui_style/white
	name = "White"
	uid  = "ui_style_white"
	override_icons = list(
		(UI_ICON_ATTACK)      = 'icons/mob/screen/styles/white/attack_selector.dmi',
		(UI_ICON_FIRE_INTENT) = 'icons/mob/screen/styles/white/fire_intent.dmi',
		(UI_ICON_HANDS)       = 'icons/mob/screen/styles/white/hands.dmi',
		(UI_ICON_INTERACTION) = 'icons/mob/screen/styles/white/interaction.dmi',
		(UI_ICON_INVENTORY)   = 'icons/mob/screen/styles/white/inventory.dmi',
		(UI_ICON_MOVEMENT)    = 'icons/mob/screen/styles/white/movement.dmi',
		(UI_ICON_UP_HINT)     = 'icons/mob/screen/styles/white/uphint.dmi',
		(UI_ICON_ZONE_SELECT) = 'icons/mob/screen/styles/white/zone_selector.dmi'
	)
	use_overlay_color = TRUE
	use_ui_color      = TRUE

/decl/ui_style/minimalist
	name = "Minimalist"
	uid  = "ui_style_minimalist"
	override_icons = list(
		(UI_ICON_ATTACK)      = 'icons/mob/screen/styles/minimalist/attack_selector.dmi',
		(UI_ICON_FIRE_INTENT) = 'icons/mob/screen/styles/minimalist/fire_intent.dmi',
		(UI_ICON_HANDS)       = 'icons/mob/screen/styles/minimalist/hands.dmi',
		(UI_ICON_INTERACTION) = 'icons/mob/screen/styles/minimalist/interaction.dmi',
		(UI_ICON_INVENTORY)   = 'icons/mob/screen/styles/minimalist/inventory.dmi',
		(UI_ICON_MOVEMENT)    = 'icons/mob/screen/styles/minimalist/movement.dmi',
		(UI_ICON_UP_HINT)     = 'icons/mob/screen/styles/minimalist/uphint.dmi',
		(UI_ICON_ZONE_SELECT) = 'icons/mob/screen/styles/minimalist/zone_selector.dmi'
	)
	use_overlay_color = TRUE
	use_ui_color      = TRUE

/decl/ui_style/underworld
	name = "Underworld"
	uid  = "ui_style_underworld"
	restricted = FALSE
	icons = list(
		(UI_ICON_ATTACK)      = 'icons/mob/screen/styles/underworld/attack_selector.dmi',
		(UI_ICON_FIRE_INTENT) = 'icons/mob/screen/styles/underworld/fire_intent.dmi',
		(UI_ICON_HANDS)       = 'icons/mob/screen/styles/underworld/hands.dmi',
		(UI_ICON_HEALTH)      = 'icons/mob/screen/styles/health.dmi',
		(UI_ICON_CRIT_MARKER) = 'icons/mob/screen/styles/crit_markers.dmi',
		(UI_ICON_HYDRATION)   = 'icons/mob/screen/styles/hydration.dmi',
		(UI_ICON_INTERACTION) = 'icons/mob/screen/styles/underworld/interaction.dmi',
		(UI_ICON_INTERNALS)   = 'icons/mob/screen/styles/internals.dmi',
		(UI_ICON_INVENTORY)   = 'icons/mob/screen/styles/underworld/inventory.dmi',
		(UI_ICON_MOVEMENT)    = 'icons/mob/screen/styles/underworld/movement.dmi',
		(UI_ICON_NUTRITION)   = 'icons/mob/screen/styles/nutrition.dmi',
		(UI_ICON_STATUS_FIRE) = 'icons/mob/screen/styles/status_fire.dmi',
		(UI_ICON_STATUS)      = 'icons/mob/screen/styles/status.dmi',
		(UI_ICON_UP_HINT)     = 'icons/mob/screen/styles/underworld/uphint.dmi',
		(UI_ICON_ZONE_SELECT) = 'icons/mob/screen/styles/underworld/zone_selector.dmi',
		(UI_ICON_CHARGE)      = 'icons/mob/screen/styles/charge.dmi'
	)
	use_overlay_color = TRUE
	use_ui_color = TRUE
