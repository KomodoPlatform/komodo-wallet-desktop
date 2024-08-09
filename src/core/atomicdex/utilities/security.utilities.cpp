/******************************************************************************
 * Copyright © 2013-2024 The Komodo Platform Developers.                      *
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

//! PCH Headers
#include "atomicdex/pch.hpp"

//! STD Headers
#include <sstream>

//! Qt
#include <QFile>

//! Deps
#include <boost/random/random_device.hpp>
#include <boost/random/uniform_int_distribution.hpp>
#include <sodium/crypto_pwhash.h>
#include <sodium/randombytes.h>
#include <sodium/utils.h>

//! Project Headers
#include "atomicdex/api/kdf/kdf.error.code.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"
#include "atomicdex/utilities/security.utilities.hpp"

namespace
{
    constexpr std::size_t g_salt_len              = crypto_pwhash_SALTBYTES;
    constexpr std::size_t g_chunk_size            = 4096;
    constexpr std::size_t g_buff_len              = (g_chunk_size + crypto_secretstream_xchacha20poly1305_ABYTES);
    constexpr std::size_t g_header_size           = crypto_secretstream_xchacha20poly1305_HEADERBYTES;
    constexpr const char* g_regex_password_policy = R"(^(?=.{16,})(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#$€£%{}[\]()\/\\'"`~,;:.<>+\-_=!^&*|?]).*$)";
    using t_salt_array                            = std::array<unsigned char, g_salt_len>;
} // namespace

namespace atomic_dex
{
    t_password_key
    derive_password(const std::string& password, std::error_code& ec)
    {
        SPDLOG_DEBUG("{} l{} f[{}]", __FUNCTION__, __LINE__, std::filesystem::path(__FILE__).filename().string());
        t_salt_array   salt{};
        t_password_key generated_crypto_key{};

        // randombytes_buf(salt.data(), salt.size()); ///< this couldn't work
        sodium_memzero(salt.data(), salt.size()); ///< this work but it's not optimal, need to find a solution later, i wonder how we could get the same salt
                                                  ///< each time without storing it

        if (crypto_pwhash(
                generated_crypto_key.data(), generated_crypto_key.size(), password.c_str(), password.size(), salt.data(), crypto_pwhash_OPSLIMIT_INTERACTIVE,
                crypto_pwhash_MEMLIMIT_INTERACTIVE, crypto_pwhash_ALG_DEFAULT) != 0)
        {
            ec = dextop_error::derive_password_failed;
            return generated_crypto_key;
        }
        SPDLOG_INFO("Key generated successfully");

        return generated_crypto_key;
    }

    void
    encrypt(const std::filesystem::path& target_path, const char* mnemonic, const unsigned char* key)
    {
        SPDLOG_DEBUG("{} l{} f[{}]", __FUNCTION__, __LINE__, std::filesystem::path(__FILE__).filename().string());

        std::array<unsigned char, g_chunk_size>     buf_in{};
        std::array<unsigned char, g_buff_len>       buf_out{};
        std::array<unsigned char, g_header_size>    header{};
        crypto_secretstream_xchacha20poly1305_state st;
        QFile                                       fp_t;
        fp_t.setFileName(std_path_to_qstring(target_path));
        fp_t.open(QIODevice::WriteOnly | QIODevice::Truncate);
        unsigned long long out_len;
        unsigned char      tag;
        std::stringstream  mnemonic_ss;

        mnemonic_ss << mnemonic;
        crypto_secretstream_xchacha20poly1305_init_push(&st, header.data(), key);
        fp_t.write(reinterpret_cast<const char*>(header.data()), header.size());
        do {
            mnemonic_ss.read(reinterpret_cast<char*>(buf_in.data()), buf_in.size());
            tag = mnemonic_ss.eof() ? crypto_secretstream_xchacha20poly1305_TAG_FINAL : 0;
            crypto_secretstream_xchacha20poly1305_push(&st, buf_out.data(), &out_len, buf_in.data(), mnemonic_ss.gcount(), nullptr, 0, tag);
            fp_t.write(reinterpret_cast<const char*>(buf_out.data()), (size_t)out_len);
        } while (not mnemonic_ss.eof());
    }

    std::string
    decrypt(const std::filesystem::path& encrypted_file_path, const unsigned char* key, std::error_code& ec)
    {
        SPDLOG_DEBUG("{} l{} f[{}]", __FUNCTION__, __LINE__, std::filesystem::path(__FILE__).filename().string());

        std::array<unsigned char, g_buff_len>       buf_in{};
        std::array<unsigned char, g_chunk_size>     buf_out{};
        std::array<unsigned char, g_header_size>    header{};
        std::stringstream                           out;
        crypto_secretstream_xchacha20poly1305_state st;
        QFile                                       fp_s;
        fp_s.setFileName(std_path_to_qstring(encrypted_file_path));
        fp_s.open(QIODevice::ReadOnly);
        unsigned long long out_len;
        unsigned char      tag;

        fp_s.read(reinterpret_cast<char*>(header.data()), header.size());
        if (crypto_secretstream_xchacha20poly1305_init_pull(&st, header.data(), key) != 0)
        {
            ec = dextop_error::wrong_password;
            return "";
        }
        do {
            auto count = fp_s.read(reinterpret_cast<char*>(buf_in.data()), buf_in.size());
            if (crypto_secretstream_xchacha20poly1305_pull(&st, buf_out.data(), &out_len, &tag, buf_in.data(), count, nullptr, 0) != 0)
            {
                ec = dextop_error::corrupted_file_or_wrong_password;
                return "";
            }
            if (tag == crypto_secretstream_xchacha20poly1305_TAG_FINAL && not fp_s.atEnd())
            {
                ec = dextop_error::corrupted_file_or_wrong_password;
                return "";
            }
            out.write(reinterpret_cast<const char*>(buf_out.data()), out_len);
        } while (not fp_s.atEnd());

        // SPDLOG_INFO("seed successfully decrypted");
        return out.str();
    }

    const char*
    get_regex_password_policy()
    {
        return g_regex_password_policy;
    }

    bool
    is_valid_generated_rpc_password(const std::string& pass)
    {
        auto lower_case_functor = [&pass]() { return std::any_of(begin(pass), end(pass), [](unsigned char c) { return std::islower(c); }); };
        auto upper_case_functor = [&pass]() { return std::any_of(begin(pass), end(pass), [](unsigned char c) { return std::isupper(c); }); };
        auto digit_functor      = [&pass]() { return std::any_of(begin(pass), end(pass), [](unsigned char c) { return std::isdigit(c); }); };
        auto is_acceptable_len  = pass.size() > 8 && pass.size() < 32;
        return lower_case_functor() && upper_case_functor() && digit_functor() && is_acceptable_len;
    }

    std::string
    gen_random_password()
    {
        std::string                               lower_case("abcdefghijklmnopqrstuvwxyz");
        std::string                               upper_case("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        std::string                               digit("1234567890");
        std::string                               special_chars("*.!@#$%^(){}:;',?/~`_+-=|");
        boost::random::random_device              rng;
        boost::random::uniform_int_distribution<> index_dist_lower(0, lower_case.size() - 1);
        boost::random::uniform_int_distribution<> index_dist_upper(0, upper_case.size() - 1);
        boost::random::uniform_int_distribution<> index_dist_digit(0, digit.size() - 1);
        boost::random::uniform_int_distribution<> index_dist_special_chars(0, special_chars.size() - 1);
        std::stringstream                         ss;
        for (int i = 0; i < 12; i += 4)
        {
            ss << lower_case[index_dist_lower(rng)];
            ss << upper_case[index_dist_upper(rng)];
            ss << digit[index_dist_digit(rng)];
            ss << special_chars[index_dist_special_chars(rng)];
        }
        return is_valid_generated_rpc_password(ss.str()) ? ss.str() : gen_random_password();
    }
} // namespace atomic_dex
