// Make psion blood usable for soulstone synthesis.
/decl/chemical_reaction/synthesis/soulstone/donor_is_magic(mob/living/donor)
	return ..() || !!donor?.get_ability_handler(/datum/ability_handler/psionics)

// Make soulstones interact with psionics.
/obj/item/soulstone/disrupts_psionics()
	. = !full ? src : FALSE

/obj/item/soulstone/shatter()
	for(var/i=1 to rand(2,5))
		new /obj/item/shard(get_turf(src), full ? /decl/material/nullglass : /decl/material/solid/gemstone/crystal)
	. = ..()

/obj/item/soulstone/withstand_psi_stress(var/stress, var/atom/source)
	. = ..(stress, source)
	if(. > 0)
		. = max(0, . - rand(2,5))
		shatter()