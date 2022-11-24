#pragma once

namespace atomic_dex
{
    inline const char*       g_dex_api{DEX_API};
    inline const std::string g_dex_rpc{DEX_RPC};
    inline const int64_t     g_dex_rpcport{std::stoi(DEX_RPCPORT)};
    inline const std::string g_primary_dex_coin{DEX_PRIMARY_COIN};
    inline const std::string g_second_primary_dex_coin{DEX_SECOND_PRIMARY_COIN};
    inline const std::vector<std::string> g_default_coins{
        g_primary_dex_coin,
        g_second_primary_dex_coin,
        "BABYDOGE-BEP20",
        "BANANO-BEP20",
        "BNB",
        "BONE-ERC20",
        "BTC",
        "CAKE",
        "CUMMIES-BEP20",
        "DOGE-BEP20",
        "DOGGY-BEP20",
        "DOGEDASH-BEP20",
        "ETH",
        "FLOKI-BEP20",
        "GM-BEP20",
        "LEASH-ERC20",
        "MONA",
        "SHIB-BEP20",
        "TAMA-BEP20",
        "SHIB-ERC20",
        "ZINU-BEP20"
    };
    inline const std::vector<std::string> g_wallet_only_coins{
        "ARRR-BEP20",
        "RBTC",
        "NVC",
        "PAXG-ERC20",
        "USDT-ERC20",
        "BET",
        "BOTS",
        "CRYPTO",
        "DEX",
        "HODL",
        "JUMBLR",
        "MGW",
        "MSHARK",
        "PANGEA",
        "REVS",
        "SUPERNET",
        "XPM",
        "ATOM"
    };
}
