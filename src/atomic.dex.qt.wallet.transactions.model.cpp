//! PCH
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.global.price.service.hpp"
#include "atomic.dex.qt.settings.page.hpp"
#include "atomic.dex.qt.wallet.transactions.model.hpp"

namespace atomic_dex
{
    transactions_model::transactions_model(ag::ecs::system_manager& system_manager, QObject* parent) noexcept :
        QAbstractListModel(parent), m_system_manager(system_manager)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("transactions model created");
    }

    transactions_model::~transactions_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("transactions model destroyed");
    }

    QHash<int, QByteArray>
    transactions_model::roleNames() const
    {
        return {
            {AmountRole, "amount"},
            {AmISenderRole, "am_i_sender"},
            {DateRole, "date"},
            {TimestampRole, "timestamp"},
            {AmountFiatRole, "amount_fiat"},
            {TxHashRole, "tx_hash"},
            {FeesRole, "fees"},
            {FromRole, "from"},
            {ToRole, "to"},
            {BlockheightRole, "blockheight"},
            {ConfirmationsRole, "confirmations"},
            {UnconfirmedRole, "unconfirmed"}};
    }

    int
    transactions_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return m_model_data.size();
    }

    QVariant
    transactions_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }
        const tx_infos& item = m_model_data.at(index.row());
        switch (static_cast<TransactionsRoles>(role))
        {
        case AmountRole:
            return item.am_i_sender ? QString::fromStdString(item.my_balance_change.substr(1)) : QString::fromStdString(item.my_balance_change);
        case AmISenderRole:
            return item.am_i_sender;
        case DateRole:
            return QString::fromStdString(item.date);
        case TimestampRole:
            return static_cast<quint64>(item.timestamp);
        case AmountFiatRole:
        {
            const auto&     currency      = this->m_system_manager.get_system<settings_page>().get_cfg().current_currency;
            const auto&     price_service = this->m_system_manager.get_system<global_price_service>();
            const auto&     mm2_system    = this->m_system_manager.get_system<mm2>();
            std::error_code ec;
            return QString::fromStdString(price_service.get_price_as_currency_from_tx(currency, mm2_system.get_current_ticker(), item, ec));
        }
        case TxHashRole:
            return QString::fromStdString(item.tx_hash);
        case FeesRole:
            return QString::fromStdString(item.fees);
        case FromRole:
        {
            QStringList out;
            out.reserve(item.from.size());
            for (auto&& cur: item.from) { out.push_back(QString::fromStdString(cur)); }
            return out;
        }
        case ToRole:
        {
            QStringList out;
            out.reserve(item.to.size());
            for (auto&& cur: item.to) { out.push_back(QString::fromStdString(cur)); }
            return out;
        }
        case BlockheightRole:
            return static_cast<quint64>(item.block_height);
        case ConfirmationsRole:
            return static_cast<quint64>(item.confirmations);
        case UnconfirmedRole:
            return item.unconfirmed;
        }
        return {};
    }


} // namespace atomic_dex