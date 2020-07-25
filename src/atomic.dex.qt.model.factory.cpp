#include "atomic.dex.qt.model.factory.hpp"

namespace atomic_dex
{
    qt_model_factory::qt_model_factory(const QObject& app, QObject* parent) : QObject(parent), m_app(app)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("model factory created");
    }

    qt_model_factory::~qt_model_factory() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("model factory destroyed");
    }
} // namespace atomic_dex