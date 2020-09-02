//! PCH
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.qt.wallet.page.hpp"

namespace atomic_dex
{
    wallet_page::wallet_page(entt::registry& registry, ag::ecs::system_manager& system_manager, QObject* parent) :
        QObject(parent), system(registry), m_system_manager(system_manager)
    {
    }

    void
    wallet_page::update() noexcept
    {
    }
} // namespace atomic_dex

//! Properties
namespace atomic_dex
{
    QString
    wallet_page::get_current_ticker() const noexcept
    {
        const auto& mm2_system = m_system_manager.get_system<mm2>();
        return QString::fromStdString(mm2_system.get_current_ticker());
    }

    void
    wallet_page::set_current_ticker(const QString& ticker) noexcept
    {
        auto& mm2_system = m_system_manager.get_system<mm2>();
        if (mm2_system.set_current_ticker(ticker.toStdString()))
        {
            emit currentTickerChanged();
        }
    }
} // namespace atomic_dex