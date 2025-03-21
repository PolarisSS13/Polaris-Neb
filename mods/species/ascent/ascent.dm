#define BODYTYPE_MANTID_SMALL "small mantid body"
#define BODYTYPE_MANTID_LARGE "large mantid body"

#define BODY_EQUIP_FLAG_ALATE BITFLAG(4)
#define BODY_EQUIP_FLAG_GYNE  BITFLAG(5)

#define BP_SYSTEM_CONTROLLER "system controller"

#define MANTIDIFY(_thing, _name, _desc) \
##_thing/ascent/name = _name; \
##_thing/ascent/desc = "Some kind of strange alien " + _desc + " technology."; \
##_thing/ascent/color = COLOR_PURPLE;

/decl/modpack/ascent
	name = "The Ascent"
