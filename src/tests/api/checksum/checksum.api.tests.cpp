//! 3rdParty
#include <doctest/doctest.h>

//! Project
#include "atomicdex/api/checksum/checksum.api.hpp"

TEST_CASE("Fetch checksum and check its value")
{
    atomic_dex::checksum::api::get_latest_checksum()
        .then([](std::string checksum)
        {
            CHECK(checksum ==
#ifdef __APPLE__
                "88460b6857bc9fa821e512c0176d39ac0ba21703013cf9a8ba0b30fcfa0d8516"
#elif __linux__
                "fce5beb83b3d8839ddb0a5187a3f129bff4ec95c3be508637dbc7805159b913e"
#elif _WIN32
                "8a5924b942a0fba96ddcc1515a560a79e698a36070b2ef7b5d38f317518423328a5924b942a0fba96ddcc1515a560a79e698a36070b2ef7b5d38f31751842332"
#endif
                 );
        })
        .then(&handle_exception_pplx_task)
        .wait();
}