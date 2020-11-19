#pragma once

//! Deps
#include <entt/core/attribute.h>

#include <QObject>

namespace atomic_dex
{
    class ENTT_API MarketModeGadget
    {
        Q_GADGET

      public:
        enum e_market_mode
        {
            Sell = 0,
            Buy  = 1
        };

        Q_ENUM(e_market_mode)

      private:
        explicit MarketModeGadget();
    };

    class ENTT_API TradingErrorGadget
    {
        Q_GADGET

      public:
        enum e_trading_error
        {
            None                                     = 0,
            NotEnoughFunds                           = 1,
            BalanceIsLessThanTheMinimalTradingAmount = 2
        };
    };
} // namespace atomic_dex

using MarketMode   = atomic_dex::MarketModeGadget::e_market_mode;
using TradingError = atomic_dex::TradingErrorGadget::e_trading_error;