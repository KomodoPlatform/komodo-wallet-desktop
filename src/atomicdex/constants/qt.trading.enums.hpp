#pragma once

#include <QObject>

namespace atomic_dex
{
    class MarketModeGadget
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
} // namespace atomic_dex

using MarketMode = atomic_dex::MarketModeGadget::e_market_mode;