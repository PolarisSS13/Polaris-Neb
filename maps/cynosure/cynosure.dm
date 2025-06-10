#if !defined(USING_MAP_DATUM)

	#include "../../mods/gamemodes/cult/_cult.dme"
	#include "../../mods/gamemodes/heist/_heist.dme"
	#include "../../mods/gamemodes/meteor/_meteor.dme"
	#include "../../mods/gamemodes/ninja/_ninja.dme"
	#include "../../mods/gamemodes/revolution/_revolution.dme"
	#include "../../mods/gamemodes/traitor/_traitor.dme"
	#include "../../mods/gamemodes/spyvspy/_spyvspy.dme"

	#include "../../mods/content/dungeon_loot/_dungeon_loot.dme"
	#include "../../mods/content/mundane.dm"
	#include "../../mods/content/standard_jobs/_standard_jobs.dme"
	#include "../../mods/content/baychems/_baychems.dme"
	#include "../../mods/content/corporate/_corporate.dme"
	#include "../../mods/content/government/_government.dme"
	#include "../../mods/content/matchmaking/_matchmaking.dme"
	#include "../../mods/content/modern_earth/_modern_earth.dme"
	#include "../../mods/content/mouse_highlights/_mouse_highlight.dme"
	#include "../../mods/content/scaling_descriptors.dm"
	#include "../../mods/content/xenobiology/_xenobiology.dme"

	#include "../../mods/mobs/dionaea/_dionaea.dme"
	#include "../../mods/mobs/borers/_borers.dme"

	// Must come after borers for compatibility.
	#include "../../mods/content/psionics/_psionics.dme"

	#include "../../mods/species/ascent/_ascent.dme"
	#include "../../mods/species/drakes/_drakes.dme"
	#include "../../mods/content/pheromones/_pheromones.dme"
	#include "../../mods/species/serpentid/_serpentid.dme"
	#include "../../mods/species/utility_frames/_utility_frames.dme"
	#include "../../mods/species/vox/_vox.dme"

	#include "../random_ruins/exoplanet_ruins/playablecolony/playablecolony.dm"

	#include "../../mods/content/polaris/_polaris.dme"
	#include "../../mods/content/government/away_sites/icarus/icarus.dm"
	#include "../../mods/content/corporate/away_sites/lar_maria/lar_maria.dm"

	#include "../../mods/species/skrell/_skrell.dme"
	#include "../../mods/species/tajaran/_tajaran.dme"
	#include "../../mods/species/unathi/_unathi.dme"
	#include "../../mods/species/teshari/_teshari.dme"

	#include "../away/liberia/liberia.dm"
	#include "../away/bearcat/bearcat.dm"
	#include "../away/casino/casino.dm"
	#include "../away/derelict/derelict.dm"
	#include "../away/errant_pisces/errant_pisces.dm"
	#include "../away/lost_supply_base/lost_supply_base.dm"
	#include "../away/magshield/magshield.dm"
	#include "../away/mining/mining.dm"
	#include "../away/mobius_rift/mobius_rift.dm"
	#include "../away/smugglers/smugglers.dm"
	#include "../away/unishi/unishi.dm"
	#include "../away/yacht/yacht.dm"

	#include "cynosure_areas.dm"
	#include "cynosure_jobs.dm"
	#include "cynosure_levels.dm"
	#include "cynosure_elevator.dm"
	#include "cynosure_presets.dm"
	#include "cynosure_shuttles.dm"
	#include "cynosure_todo.dm"

	#include "loadout/loadout_accessories.dm"
	#include "loadout/loadout_head.dm"
	#include "loadout/loadout_suit.dm"
	#include "loadout/loadout_uniform.dm"

	#include "datums/supplypacks/munitions.dm"
	#include "datums/random_map.dm"
	#include "datums/spawn.dm"

	#include "items/clothing/cyno_exploration.dm"
	#include "items/clothing/cyno_permits.dm"
	#include "items/clothing/cyno_suit.dm"
	#include "job/outfits.dm"
	#include "structures/closets/misc.dm"
	#include "structures/closets/security.dm"
	#include "turfs/voidcraft.dm"

	//#include "overmap/sectors.dm"

	#include "cynosure-1.dmm"
	#include "cynosure-2.dmm"
	#include "cynosure-3.dmm"
	#include "cynosure-4.dmm"
	#include "cynosure-5.dmm"
	#include "cynosure-6.dmm"

	//#include "submaps/_cynosure_submaps.dm"

	#define USING_MAP_DATUM /datum/map/cynosure

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Cynosure

#endif
