//! PCH
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.qt.wallet.transactions.model.hpp"

namespace atomic_dex
{
    transactions_model::transactions_model(QObject* parent) noexcept : QAbstractListModel(parent)
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
            {ConfirmationsRole, "confirmations"}};
    }

    int
    transactions_model::rowCount(const QModelIndex& parent) const
    {
        return m_model_data.size();
    }

    QVariant
    transactions_model::data(const QModelIndex& index, int role) const
    {
        return QVariant();
    }


} // namespace atomic_dex