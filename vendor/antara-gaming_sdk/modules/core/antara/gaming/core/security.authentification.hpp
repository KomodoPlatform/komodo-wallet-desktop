#pragma once

#include <functional>
#include <string>

namespace antara::gaming::core
{
    void evaluate_authentication(const std::string& auth_reason, std::function<void(bool)> handler);
}