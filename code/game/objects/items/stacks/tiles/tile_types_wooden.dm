#define WOOD_TILE_SUBTYPE(MAT_NAME, STACK_TYPE, MAT_TYPE)                  \
/obj/item/stack/tile/wood/##STACK_TYPE {                                   \
	name              = MAT_NAME + " floor tile";                          \
	singular_name     = MAT_NAME + " floor tile";                          \
	plural_name       = MAT_NAME + " floor tiles";                         \
	desc              = "An easy-to-fit " + MAT_NAME + " floor tile.";     \
	color             = /decl/material/solid/organic/wood/MAT_TYPE::color; \
	material          = /decl/material/solid/organic/wood/MAT_TYPE;        \
}

/obj/item/stack/tile/wood/cyborg
	name              = "wood floor tile synthesizer"
	singular_name     = "wood floor tile"
	desc              = "A device that makes laminated wooden floor tiles."
	uses_charge       = 1
	charge_costs      = list(250)
	stack_merge_type  = /obj/item/stack/tile/wood/laminate
	build_type        = /obj/item/stack/tile/wood/laminate
	color             = /decl/material/solid/organic/wood/chipboard::color
	material          = /decl/material/solid/organic/wood/chipboard
	max_health        = ITEM_HEALTH_NO_DAMAGE
	is_spawnable_type = FALSE

/obj/item/stack/tile/wood
	abstract_type = /obj/item/stack/tile/wood
	icon_state    = "tile-wood"

/obj/item/stack/tile/wood/laminate
	abstract_type = /obj/item/stack/tile/wood/laminate

WOOD_TILE_SUBTYPE("oak",               oak,               oak)
WOOD_TILE_SUBTYPE("mahogany",          mahogany,          mahogany)
WOOD_TILE_SUBTYPE("maple",             maple,             maple)
WOOD_TILE_SUBTYPE("ebony",             ebony,             ebony)
WOOD_TILE_SUBTYPE("walnut",            walnut,            walnut)
WOOD_TILE_SUBTYPE("bamboo",            bamboo,            bamboo)
WOOD_TILE_SUBTYPE("yew",               yew,               yew)
WOOD_TILE_SUBTYPE("oak laminate",      laminate/oak,      chipboard)
WOOD_TILE_SUBTYPE("mahogany laminate", laminate/mahogany, chipboard/mahogany)
WOOD_TILE_SUBTYPE("maple laminate",    laminate/maple,    chipboard/maple)
WOOD_TILE_SUBTYPE("ebony laminate",    laminate/ebony,    chipboard/ebony)
WOOD_TILE_SUBTYPE("walnut laminate",   laminate/walnut,   chipboard/walnut)
WOOD_TILE_SUBTYPE("yew laminate",      laminate/yew,      chipboard/yew)
