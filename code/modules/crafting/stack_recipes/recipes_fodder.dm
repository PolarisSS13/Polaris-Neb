/decl/stack_recipe/fodder
	result_type       = /obj/structure/haystack
	required_material = /decl/material/solid/organic/plantmatter/grass/dry
	craft_stack_types = list(/obj/item/stack/material/bundle)
	one_per_turf      = TRUE
	on_floor          = TRUE
	difficulty        = MAT_VALUE_EASY_DIY
	recipe_skill      = SKILL_BOTANY

/decl/stack_recipe/fodder/get_required_stack_amount(obj/item/stack/stack)
	return 30 // Arbitrary amount to make 20 food items.

/decl/stack_recipe/fodder/bale
	result_type       = /obj/structure/haystack/bale
