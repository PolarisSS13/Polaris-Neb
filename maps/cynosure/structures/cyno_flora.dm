/obj/structure/flora
	var/randomize_size = FALSE
	var/max_x_scale = 1.25
	var/max_y_scale = 1.25
	var/min_x_scale = 0.9
	var/min_y_scale = 0.9

/obj/structure/flora/Initialize(ml, _mat, _reinf_mat)
	. = ..()
	if(randomize_size)
		icon_scale_x = rand(min_x_scale * 100, max_x_scale * 100) / 100
		icon_scale_y = rand(min_y_scale * 100, max_y_scale * 100) / 100

		if(prob(50))
			icon_scale_x *= -1
		update_transform()

/obj/structure/flora/sif
	abstract_type = /obj/structure/flora/sif
	icon = 'maps/cynosure/icons/obj/flora/flora_sif.dmi'

/obj/structure/flora/sif/attackby(obj/item/tool, mob/user)
	if(tool.do_tool_interaction(TOOL_SHOVEL, user, src, 5 SECONDS, "uprooting", "uprooting", check_skill = SKILL_BOTANY))
		user.visible_message(SPAN_NOTICE("\The [user] uproots \the [src] with \the [tool]!"), SPAN_NOTICE("You uproot \the [src] with \the [tool]!"))
		physically_destroyed()
		return TRUE
	return ..()

/obj/structure/flora/sif/eyes
	name = "mysterious bulbs"
	desc = "This is a mysterious looking plant. They kind of look like eyeballs. Creepy."
	icon_state = "eyeplant"

/obj/structure/flora/sif/eyes/Initialize(mapload)
	icon_state = "[initial(icon_state)][rand(1,3)]"
	. = ..()

/obj/structure/flora/sif/tendrils
	name = "stocky tendrils"
	desc = "A 'plant' made up of hardened moss. It has tiny hairs that bunch together to look like snow."
	icon_state = "grass1"
	randomize_size = TRUE

/obj/structure/flora/sif/tendrils/init_appearance()
	icon_state = "grass[rand(0,2)]"

// Small jungle trees

/obj/structure/flora/tree/jungle_small
	icon = 'maps/cynosure/icons/obj/flora/tree_jungle_small.dmi'
	icon_state = "tree"
	stump_type = /obj/structure/flora/stump/tree/jungle_small
	max_health = 400
	pixel_x = -32

/obj/structure/flora/tree/jungle_small/init_appearance()
	icon_state = "[initial(icon_state)][rand(1, 6)]"

/obj/structure/flora/stump/tree/jungle_small
	icon = 'maps/cynosure/icons/obj/flora/tree_jungle_small.dmi'
	icon_state = "tree_stump"

// Big jungle trees

/obj/structure/flora/tree/jungle
	icon = 'maps/cynosure/icons/obj/flora/tree_jungle.dmi'
	icon_state = "tree"
	stump_type = /obj/structure/flora/stump/tree/jungle
	log_amount = 20
	max_health = 800
	pixel_x = -48
	pixel_y = -16
	shake_animation_degrees = 2

/obj/structure/flora/tree/jungle/init_appearance()
	icon_state = "[initial(icon_state)][rand(1, 6)]"

/obj/structure/flora/stump/tree/jungle
	icon = 'maps/cynosure/icons/obj/flora/tree_jungle.dmi'
	icon_state = "tree_stump"

/obj/structure/flora/tree/sif
	name = "glowing tree"
	desc = "It's a tree, except this one seems quite alien.  It glows a deep blue."
	icon = 'maps/cynosure/icons/obj/flora/tree_sif.dmi'
	icon_state = "tree_sif0"
	stump_type = /obj/structure/flora/stump/tree/sif
	// todo: add harvest product and alien sivian wood
	// product = /obj/item/stack/material/log/sif
	randomize_size = TRUE

/obj/structure/flora/tree/sif/Initialize(ml, _mat, _reinf_mat)
	. = ..()
	set_light(3-rand(0,3), 1, "#33ccff")

/obj/structure/flora/stump/tree/sif
	icon = 'maps/cynosure/icons/obj/flora/tree_sif.dmi'
	icon_state = "tree_sif_stump"

/obj/structure/flora/tree/sif/init_appearance()
	icon_state = "tree_sif[rand(0, 5)]"
	update_icon()

/obj/structure/flora/tree/sif/on_update_icon()
	. = ..()
	set_overlays(emissive_overlay(icon, "[icon_state]_glow"))