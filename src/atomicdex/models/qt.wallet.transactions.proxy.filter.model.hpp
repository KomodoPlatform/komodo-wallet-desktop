#pragma once

#include <QSortFilterProxyModel>

namespace atomic_dex
{
    class transactions_proxy_model final : public QSortFilterProxyModel
    {
      Q_OBJECT

      public:
        //! Constructor
        transactions_proxy_model(QObject* parent);

        //! Destructor
        ~transactions_proxy_model() final;

      protected:
        //! Override member functions
        [[nodiscard]] bool lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const final;
    };
}
