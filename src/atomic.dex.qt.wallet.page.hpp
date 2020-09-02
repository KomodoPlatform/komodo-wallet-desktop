#pragma once

//! QT Headers
#include <QObject>
#include <QVariant>

namespace atomic_dex
{
    class wallet_page final : public QObject, public ag::ecs::pre_update_system<wallet_page>
    {
        //! Q_Object definition
        Q_OBJECT

        //! Properties
        Q_PROPERTY(QString ticker READ get_current_ticker WRITE set_current_ticker NOTIFY currentTickerChanged)
        Q_PROPERTY(QVariant ticker_infos READ get_ticker_infos NOTIFY tickerInfosChanged)

        ag::ecs::system_manager& m_system_manager;

      public:
        explicit wallet_page(entt::registry& registry, ag::ecs::system_manager& system_manager, QObject* parent = nullptr);
        void update() noexcept override;
        ~wallet_page() noexcept final = default;

        //! Public API
        void refresh_ticker_infos() noexcept;

        //! Properties
        [[nodiscard]] QString  get_current_ticker() const noexcept;
        void                   set_current_ticker(const QString& ticker) noexcept;
        [[nodiscard]] QVariant get_ticker_infos() const noexcept;
      signals:
        void currentTickerChanged();
        void tickerInfosChanged();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::wallet_page))