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

#pragma once

//! PCH Headers
#include <atomic.dex.pch.hpp>

namespace
{
    constexpr std::size_t g_salt_len              = crypto_pwhash_SALTBYTES;
    constexpr std::size_t g_key_len               = crypto_secretstream_xchacha20poly1305_KEYBYTES;
    constexpr std::size_t g_chunk_size            = 4096;
    constexpr std::size_t g_buff_len              = (g_chunk_size + crypto_secretstream_xchacha20poly1305_ABYTES);
    constexpr std::size_t g_header_size           = crypto_secretstream_xchacha20poly1305_HEADERBYTES;
    constexpr const char* g_regex_password_policy = R"(^(?=.{16,})(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#$%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?]).*$)";
    using t_password_key                          = std::array<unsigned char, g_key_len>;
} // namespace

namespace atomic_dex
{
    t_password_key derive_password(const std::string& password, std::error_code& ec);
    void           encrypt(const fs::path& target_path, const char* mnemonic, const unsigned char* key);
    std::string    decrypt(const fs::path& encrypted_file_path, const unsigned char* key, std::error_code& ec);
    std::string    gen_random_password() noexcept;
    const char*    get_regex_password_policy();
} // namespace atomic_dex