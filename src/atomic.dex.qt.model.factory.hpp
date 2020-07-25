#pragma once

#include <QAbstractItemModel>
#include <QObject>

#include "atomic.dex.app.hpp"

namespace atomic_dex
{
    class qt_model_factory final : public QObject
    {
        Q_OBJECT
      public:
        qt_model_factory(const application& app, QObject* parent = nullptr);
        ~qt_model_factory() noexcept final;

        template <typename TConcreteModel>
        TConcreteModel*
        get_model(const std::string& model_name) const noexcept
        {
            return qobject_cast<TConcreteModel*>(m_model_registry.at(model_name));
        }

      private:
        const application&                                   m_app;
        std::unordered_map<std::string, QAbstractItemModel*> m_model_registry;
    };
} // namespace atomic_dex