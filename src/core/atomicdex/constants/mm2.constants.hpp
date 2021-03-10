#pragma once

//! Qt
#include <QObject>

namespace atomic_dex
{
    constexpr const char* g_qtum_infos_endpoint = "https://qtum.info/api/";
    inline const std::vector<std::string> default_coins{"KMD", "BTC"};
} // namespace atomic_dex