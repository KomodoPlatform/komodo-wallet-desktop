//! PCH
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.global.price.service.hpp"
#include "atomic.dex.qt.settings.page.hpp"
#include "atomic.dex.qt.wallet.manager.hpp"
#include "atomic.dex.qt.wallet.transactions.model.hpp"

namespace
{
    template <typename TModel>
    auto
    update_value(int role, const QVariant& value, const QModelIndex& idx, TModel& model)
    {
        if (auto prev_value = model.data(idx, role); value != prev_value)
        {
            model.setData(idx, value, role);
            return std::make_tuple(prev_value, value, true);
        }
        return std::make_tuple(value, value, false);
    }
} // namespace

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
            {UnconfirmedRole, "unconfirmed"},
            {TransactionNoteRole, "transaction_note"}};
    }

    int
    transactions_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        // return m_model_data.size();
        return static_cast<int>(m_file_count);
    }

    bool
    atomic_dex::transactions_model::setData(const QModelIndex& index, const QVariant& value, int role)
    {
        if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
        {
            return false;
        }

        tx_infos& item = m_model_data[index.row()];
        switch (static_cast<TransactionsRoles>(role))
        {
        case AmountRole:
            break;
        case AmISenderRole:
            break;
        case DateRole:
            item.date = value.toString().toStdString();
            break;
        case TimestampRole:
            item.timestamp = value.toULongLong();
            break;
        case AmountFiatRole:
            break;
        case TxHashRole:
            break;
        case FeesRole:
            break;
        case FromRole:
            break;
        case ToRole:
            break;
        case BlockheightRole:
            item.block_height = value.toUInt();
            break;
        case ConfirmationsRole:
            item.confirmations = value.toUInt();
            break;
        case UnconfirmedRole:
            item.unconfirmed = value.toBool();
            break;
        case TransactionNoteRole:
        {
            item.transaction_note = value.toString().toStdString();
            auto& wallet_manager  = this->m_system_manager.get_system<qt_wallet_manager>();
            wallet_manager.update_transactions_notes(item.tx_hash, item.transaction_note);
            wallet_manager.update_wallet_cfg();
            break;
        }
        }
        emit dataChanged(index, index, {role});
        return true;
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
        case TransactionNoteRole:
            return QString::fromStdString(item.transaction_note);
        }
        return {};
    }

    void
    atomic_dex::transactions_model::reset()
    {
        this->m_file_count = 0;
        this->beginResetModel();
        this->m_model_data.clear();
        this->endResetModel();
        emit lengthChanged();
    }

    void
    transactions_model::init_transactions(const t_transactions& transactions)
    {
        if (m_model_data.size() == 0)
        {
            spdlog::trace("first time initialization, inserting {} transactions", transactions.size());
            //! First time insertion
            beginResetModel();
            m_model_data = transactions;
            m_file_count = 0;
            endResetModel();
        }
        else
        {
            //! Other time insertion
            spdlog::trace("other time insertion, from {} to {}", m_file_count, m_file_count + transactions.size());
            beginInsertRows(QModelIndex(), m_file_count, m_file_count + transactions.size() - 1);
            m_file_count += transactions.size();
            m_model_data.insert(end(m_model_data), begin(transactions), end(transactions));
            endInsertRows();
        }
        spdlog::trace("transactions model size: {}", rowCount());
        emit lengthChanged();
    }

    void
    atomic_dex::transactions_model::update_transaction(const tx_infos& tx)
    {
        if (const auto res = this->match(this->index(0, 0), TxHashRole, QString::fromStdString(tx.tx_hash)); not res.isEmpty())
        {
            const QModelIndex& idx       = res.at(0);
            quint64            timestamp = tx.timestamp;
            update_value(TimestampRole, timestamp, idx, *this);
            update_value(DateRole, QString::fromStdString(tx.date), idx, *this);
            update_value(ConfirmationsRole, static_cast<quint64>(tx.confirmations), idx, *this);
            update_value(UnconfirmedRole, tx.unconfirmed, idx, *this);
        }
    }

    void
    atomic_dex::transactions_model::update_or_insert_transactions(const t_transactions& transactions)
    {
        if (m_model_data.size() > transactions.size())
        {
            spdlog::warn("old model data already bigger than the new one, bypassing");
            return;
        }
        t_transactions to_init;
        auto           difference = transactions.size() - this->m_model_data.size();
        spdlog::trace("difference between old transactions call and new transactions is: {}", difference);
        spdlog::trace("new transactions size is: {}, old one is: {}", transactions.size(), m_model_data.size());
        if (difference > 0)
        {
            //! There is new transactions
            to_init = t_transactions(transactions.begin(), transactions.begin() + difference);
        }
        spdlog::trace("updating transactions");
        std::for_each(begin(transactions) + difference, end(transactions), [this](const tx_infos& tx) { this->update_transaction(tx); });
        if (not to_init.empty())
        {
            spdlog::trace("to init transactions started: {}", to_init.size());
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

    void
    atomic_dex::transactions_model::fetchMore(const QModelIndex& parent)
    {
        if (parent.isValid())
        {
            return;
        }
        int remainder      = m_model_data.size() - m_file_count;
        int items_to_fetch = qMin(50, remainder);
        if (items_to_fetch <= 0)
        {
            return;
        }
        spdlog::trace("fetching {} transactions, total tx: {}", items_to_fetch, m_model_data.size());
        beginInsertRows(QModelIndex(), m_file_count, m_file_count + items_to_fetch - 1);
        m_file_count += items_to_fetch;
        endInsertRows();
        emit lengthChanged();
    }

    bool
    atomic_dex::transactions_model::canFetchMore([[maybe_unused]] const QModelIndex& parent) const
    {
        return (m_file_count < m_model_data.size());
    }

} // namespace atomic_dex