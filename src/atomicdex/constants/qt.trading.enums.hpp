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
        enum MarketModeEnum
        {
            Sell = 0,
            Buy  = 1
        };

        Q_ENUM(MarketModeEnum)

      private:
        explicit MarketModeGadget();
    };

    class ENTT_API TradingErrorGadget
    {
        Q_GADGET

      public:
        enum TradingErrorEnum
        {
            None                                     = 0,
            BaseNotEnoughFunds                       = 1,
            RelNotEnoughFunds                        = 2,
            BalanceIsLessThanTheMinimalTradingAmount = 3
        };

        Q_ENUM(TradingErrorEnum)

      private:
        explicit TradingErrorGadget();
    };
} // namespace atomic_dex

using MarketMode   = atomic_dex::MarketModeGadget::MarketModeEnum;
using TradingError = atomic_dex::TradingErrorGadget::TradingErrorEnum;