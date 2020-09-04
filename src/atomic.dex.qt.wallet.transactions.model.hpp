#pragma once

#include <QAbstractListModel>
#include <QObject>

#include "atomic.dex.mm2.hpp"

namespace atomic_dex
{
    class transactions_model final : public QAbstractListModel
    {
        Q_OBJECT
        Q_PROPERTY(int length READ get_length NOTIFY lengthChanged);

        using t_tx_registry = std::unordered_set<std::string>;

        ag::ecs::system_manager& m_system_manager;
        t_transactions           m_model_data;
        t_tx_registry            m_tx_registry;

      public:
        enum TransactionsRoles
        {
            AmountRole = Qt::UserRole + 1,
            AmISenderRole,
            DateRole,
            TimestampRole,
            AmountFiatRole,
            TxHashRole,
            FeesRole,
            FromRole,
            ToRole,
            BlockheightRole,
            ConfirmationsRole,
            UnconfirmedRole
        };

        transactions_model(ag::ecs::system_manager& system_manager, QObject* parent = nullptr) noexcept;
        ~transactions_model() noexcept final;

        void reset();
        void init_transactions(const t_transactions& transactions);

        //! Override
        [[nodiscard]] QHash<int, QByteArray> roleNames() const final;
        QVariant                             data(const QModelIndex& index, int role) const final;
        int                                  rowCount(const QModelIndex& parent = QModelIndex()) const final;

        //! Props
        [[nodiscard]] int get_length() const noexcept;;

      signals:
        void lengthChanged();
    };
} // namespace atomic_dex