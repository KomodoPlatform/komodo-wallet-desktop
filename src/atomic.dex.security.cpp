/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
 *                                                                            *
 * See the AUTHORS, DEVELOPER-AGREEMENT and LICENSE files at                  *
 * the top-level directory of this distribution for the individual copyright  *
 * holder information and the developer policies on copyright and licensing.  *
 *                                                                            *
 * Unless otherwise agreed in a custom licensing agreement, no part of the    *
 * Komodo Platform software, including this file may be copied, modified,     *
 * propagated or distributed except according to the terms contained in the   *
 * LICENSE file                                                               *
 *                                                                            *
 * Removal or modification of this copyright notice is prohibited.            *
 *                                                                            *
 ******************************************************************************/

//! Project Headers
#include "atomic.dex.security.hpp"
#include "atomic.dex.mm2.error.code.hpp"

namespace
{
    inline constexpr std::size_t g_salt_len = crypto_pwhash_SALTBYTES;
    inline constexpr std::size_t g_key_len  = crypto_secretstream_xchacha20poly1305_KEYBYTES;
} // namespace

namespace atomic_dex
{
    auto
    derive_password(const std::string& password, std::error_code& ec)
    {
        LOG_SCOPE_FUNCTION(INFO);
        std::array<unsigned char, g_salt_len> salt{};
        std::array<unsigned char, g_key_len>  generated_crypto_key{};

        sodium_memzero(salt.data(), salt.size());
        // randombytes_buf(salt.data(), salt.size());

        if (crypto_pwhash(
                generated_crypto_key.data(), generated_crypto_key.size(), password.c_str(), password.size(), salt.data(), crypto_pwhash_OPSLIMIT_INTERACTIVE,
                crypto_pwhash_MEMLIMIT_INTERACTIVE, crypto_pwhash_ALG_DEFAULT) != 0)
        {
            ec = dextop_error::derive_password_failed;
            return generated_crypto_key;
        }
        else
        {
            LOG_F(INFO, "Key generated successfully");
        }

        return generated_crypto_key;
    }
} // namespace atomic_dex
