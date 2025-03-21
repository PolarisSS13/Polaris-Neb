/decl/flooring/reinforced/cult
	name       = "engraved floor"
	desc       = "Unsettling whispers waver from the surface..."
	icon       = 'icons/turf/flooring/cult.dmi'
	icon_base  = "cult"
	build_type = null
	turf_flags = TURF_ACID_IMMUNE | TURF_REMOVE_WRENCH
	can_paint  = FALSE

/decl/flooring/reinforced/cult/on_flooring_remove(turf/removing_from)
	var/decl/special_role/cultist/cult = GET_DECL(/decl/special_role/cultist)
	cult.remove_cultiness(CULTINESS_PER_TURF)
