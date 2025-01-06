/decl/flooring/wood/sif
	color              = /decl/material/solid/organic/wood/sivian::color
	build_type         = /obj/item/stack/tile/wood/sivian
	force_material     = /decl/material/solid/organic/wood/sivian

/decl/flooring/wood/rough/sif
	color              = /decl/material/solid/organic/wood/sivian::color
	build_type         = /obj/item/stack/tile/wood/rough/sivian
	force_material     = /decl/material/solid/organic/wood/sivian

/decl/flooring/grass/sif
	name = "growth"
	desc = "A layer of Sivian moss that has adapted to the sheer cold climate."
	color = "#447171"
	force_material = /decl/material/solid/organic/plantmatter/grass/sif

/decl/flooring/grass/wild/sif
	name = "thick growth"
	desc = "A thick, rough layer of Sivian moss that has adapted to the sheer cold climate."
	color = "#446471"

/decl/flooring/tiling/steel_dirty
	build_type = /obj/item/stack/tile/floor_steel_dirty

/obj/item/stack/tile/floor_steel_dirty
	name = "dirty steel tile"
	singular_name = "dirty steel tile"
	icon_state = "tile"
	material = /decl/material/solid/metal/steel
	obj_flags = OBJ_FLAG_CONDUCTIBLE

WOOD_TILE_SUBTYPE("sifwood",       sivian,       sivian)
WOOD_TILE_SUBTYPE("rough sifwood", rough/sivian, sivian)

/turf/floor/wood/sif
	_flooring = /decl/flooring/wood/sif

/turf/floor/wood/broken/sif
	_flooring = /decl/flooring/wood/sif

/turf/floor/tiled/steel_dirty
	_flooring = /decl/flooring/tiling/steel_dirty

/turf/floor/grass/sif
	name = "growth"
	color = "#447171"
	_flooring = /decl/flooring/grass/sif

/turf/floor/grass/wild/sif
	name = "thick growth"
	color = "#446471"
	_flooring = /decl/flooring/grass/wild/sif

// TODO:
/turf/floor/tiled/yellow
/turf/floor/tiled/milspec
/turf/floor/tiled/milspec/dark
/turf/floor/tiled/milspec/raised
/turf/floor/tiled/milspec/sterile
/turf/floor/tiled/hydro
/turf/floor/tiled/old_tile
/turf/floor/tiled/old_tile/gray
/turf/floor/tiled/old_tile/white
/turf/floor/tiled/old_tile/yellow
/turf/floor/tiled/old_tile/blue
/turf/floor/tiled/old_cargo
/turf/floor/tiled/old_cargo/gray
/turf/floor/tiled/old_cargo/white
/turf/floor/tiled/old_cargo/blue
/turf/floor/tiled/neutral
/turf/floor/tiled/asteroid_steel
/turf/floor/tiled/kafel_full/gray
/turf/floor/tiled/eris
/turf/floor/tiled/eris/cafe
/turf/floor/tiled/eris/steel
/turf/floor/tiled/eris/steel/danger
