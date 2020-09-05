//! PCH
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.global.price.service.hpp"
#include "atomic.dex.qt.settings.page.hpp"
#include "atomic.dex.qt.wallet.transactions.model.hpp"

namespace atomic_dex
{
    transactions_model::transactions_model(ag::ecs::system_manager& system_manager, QObject* parent) noexcept :
        QAbstractListModel(parent), m_system_manager(system_manager), m_model_proxy(new transactions_proxy_model(this))
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("transactions model created");
        this->m_model_proxy->setSourceModel(this);
        this->m_model_proxy->setDynamicSortFilter(true);
        this->m_model_proxy->setSortRole(TimestampRole);
        this->m_model_proxy->sort(0);
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

    void
    atomic_dex::transactions_model::reset()
    {
        this->m_tx_registry.clear();
        this->beginResetModel();
        this->m_model_data.clear();
        this->endResetModel();
        emit lengthChanged();
    }

    void
    transactions_model::init_transactions(const t_transactions& transactions)
    {
        for (auto&& tx: transactions)
        {
            spdlog::trace("insering tx [{}] to the model, timestamp: {}", tx.tx_hash, tx.timestamp);
            m_tx_registry.emplace(tx.tx_hash);
        }
        beginInsertRows(QModelIndex(), this->m_model_data.size(), this->m_model_data.size() + transactions.size() - 1);
        m_model_data.insert(end(m_model_data), begin(transactions), end(transactions));
        endInsertRows();
        spdlog::trace("transactions model size: {}", m_model_data.size());
        emit lengthChanged();
    }

    void
    atomic_dex::transactions_model::update_or_insert_transactions(const t_transactions& transactions)
    {
        t_transactions to_init;
        for (auto&& tx: transactions)
        {
            if (m_tx_registry.find(tx.tx_hash) == m_tx_registry.end())
            {
                spdlog::trace("need to init: {}", tx.tx_hash);
                to_init.push_back(tx);
            }
            else
            {
                //! Need to update
            }
        }
        if (not to_init.empty())
        {
            this->init_transactions(to_init);
        }
    }

    int
    transactions_model::get_length() const noexcept
    {
        return rowCount();
    }

    transactions_proxy_model*
    transactions_model::get_transactions_proxy() const noexcept
    {
        return m_model_proxy;
    }

} // namespace atomic_dex