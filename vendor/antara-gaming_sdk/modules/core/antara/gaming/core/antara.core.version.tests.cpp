//
// Created by roman on 10/09/2019.
//

#include "antara/gaming/core/version.hpp"
#include <cstring>
#include <doctest/doctest.h>

TEST_CASE("test version")
{
    CHECK(std::strlen(antara::gaming::version()) > 0);
}