//
// Created by Roman Szterg on 23/01/2021.
//

#include "antara/gaming/core/security.authentification.hpp"

#ifdef _WIN32

#    include "antara/gaming/core/details/windows/security.authentification.hpp"

#elif __APPLE__

#    include "antara/gaming/core/details/osx/security.authentification.hpp"

#elif __linux__

#    include "antara/gaming/core/details/linux/security.authentification.hpp"

#endif

namespace antara::gaming::core
{
    void evaluate_authentication(const std::string& auth_reason, std::function<void(bool)> handler)
    {
        return details::evaluate_authentication(auth_reason, handler);
    }
} // namespace antara::gaming::core