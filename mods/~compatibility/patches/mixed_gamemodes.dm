// TODO: #ifdef GAMEMODE_PACK_MERCENARY
#if defined(GAMEMODE_PACK_HEIST)
#include "mixed_gamemodes/crossfire.dm"
#endif
#if defined(GAMEMODE_PACK_REVOLUTIONARY)
#include "mixed_gamemodes/siege.dm"
#endif
// #endif

#if defined(GAMEMODE_PACK_REVOLUTIONARY) && defined(GAMEMODE_PACK_CULT)
#include "mixed_gamemodes/uprising.dm"
#endif