// Override drake lore and names for the fantasy modpack.
#ifdef MODPACK_DRAKES
#include "fantasy/drake_fantasy.dm"
#endif

// Make whetstones available for the fantasy modpack/
#ifdef MODPACK_ITEM_SHARPENING
#include "fantasy/whetstone_fantasy.dm"
#endif

#ifdef MODPACK_BLACKSMITHY
#include "fantasy/forging_fantasy.dm"
#endif