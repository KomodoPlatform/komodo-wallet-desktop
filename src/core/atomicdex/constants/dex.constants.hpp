#pragma once

namespace atomic_dex
{
    inline const std::string g_primary_dex_coin{DEX_PRIMARY_COIN};
    inline const std::string g_second_primary_dex_coin{DEX_SECOND_PRIMARY_COIN};
    inline const std::vector<std::string> g_default_coins{g_primary_dex_coin, g_second_primary_dex_coin};
}