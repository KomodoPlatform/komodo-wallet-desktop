/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

#pragma once

//! Deps
#include <sodium/crypto_secretstream_xchacha20poly1305.h>

namespace atomic_dex
{
    inline constexpr std::size_t g_key_len = crypto_secretstream_xchacha20poly1305_KEYBYTES;
    using t_password_key                   = std::array<unsigned char, g_key_len>;
    t_password_key derive_password(const std::string& password, std::error_code& ec);
    void           encrypt(const fs::path& target_path, const char* mnemonic, const unsigned char* key);
    std::string    decrypt(const fs::path& encrypted_file_path, const unsigned char* key, std::error_code& ec);
    bool           is_valid_generated_rpc_password(const std::string& pass);
    std::string    gen_random_password();
    const char*    get_regex_password_policy();
} // namespace atomic_dex
