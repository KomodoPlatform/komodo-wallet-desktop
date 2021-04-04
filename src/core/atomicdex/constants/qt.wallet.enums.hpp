#pragma once

//! QGadget
#include <QObject>

//! Deps
#include <entt/core/attribute.h>

namespace atomic_dex
{
    class ENTT_API WalletChartsCategoriesGadget
    {
        Q_GADGET

      public:
        enum WalletChartsCategoriesEnum
        {
            OneDay = 0,
            OneWeek,
            OneMonth,
            Ytd,
            Size
        };

        Q_ENUM(WalletChartsCategoriesEnum)

      private:
        explicit WalletChartsCategoriesGadget();
    };
} // namespace atomic_dex

using WalletChartsCategories = atomic_dex::WalletChartsCategoriesGadget::WalletChartsCategoriesEnum;