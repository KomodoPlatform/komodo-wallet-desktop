//! PCH
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.qt.wallet.transactions.model.hpp"
#include "atomic.dex.qt.wallet.transactions.proxy.filter.model.hpp"

namespace atomic_dex
{
    transactions_proxy_model::transactions_proxy_model(QObject* parent) : QSortFilterProxyModel(parent)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("transactions proxy model created");
    }

    transactions_proxy_model::~transactions_proxy_model()
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("transactions proxy model destroyed");
    }

    bool
    transactions_proxy_model::lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const
    {
        int      role       = this->sortRole();
        QVariant left_data  = sourceModel()->data(source_left, role);
        QVariant right_data = sourceModel()->data(source_right, role);
        switch (static_cast<atomic_dex::transactions_model::TransactionsRoles>(role))
        {
        case transactions_model::AmountRole:
            break;
        case transactions_model::AmISenderRole:
            break;
        case transactions_model::DateRole:
            break;
        case transactions_model::TimestampRole:
            return left_data.toUInt() > right_data.toUInt();
        case transactions_model::AmountFiatRole:
            break;
        case transactions_model::TxHashRole:
            break;
        case transactions_model::FeesRole:
            break;
        case transactions_model::FromRole:
            break;
        case transactions_model::ToRole:
            break;
        case transactions_model::BlockheightRole:
            break;
        case transactions_model::ConfirmationsRole:
            break;
        case transactions_model::UnconfirmedRole:
            break;
        }
        return true;
    }
} // namespace atomic_dex