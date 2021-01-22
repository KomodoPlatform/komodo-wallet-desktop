#pragma once

#include <functional>

//! Qt
#include <QString>

namespace atomic_dex
{
    // Asks user to authenticate. Accepts a callback parameter where the first parameter tells if the authentication succeeded or not.
    // Since a part of this function where the callback is used is async, it is taken by copy.
    void evaluate_authentication(const QString& auth_reason, std::function<void(bool)> handler);
}