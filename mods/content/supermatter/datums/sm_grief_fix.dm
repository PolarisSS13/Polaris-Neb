/decl/atmos_grief_fix_step/supermatter
	name = "Supermatter depowered"
	sort_order = 0

/decl/atmos_grief_fix_step/supermatter/act()
	// Depower the supermatter, as it would quickly blow up once we remove all gases from the pipes.
	for(var/obj/machinery/power/supermatter/S in SSmachines.machinery)
		S.power = 0