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

#include <nlohmann/json.hpp>

namespace atomic_dex::utils::details
{
    struct my_json_sax : nlohmann::json_sax<nlohmann::json>
    {
        bool binary([[maybe_unused]] binary_t& val) override;

        bool null() override;

        bool boolean([[maybe_unused]] bool val) override;

        bool number_integer([[maybe_unused]] number_integer_t val) override;

        bool number_unsigned([[maybe_unused]] number_unsigned_t val) override;

        bool number_float([[maybe_unused]] number_float_t val, [[maybe_unused]] const string_t& s) override;

        bool string([[maybe_unused]] string_t& val) override;

        bool start_object([[maybe_unused]] std::size_t elements) override;

        bool key([[maybe_unused]] string_t& val) override;

        bool end_object() override;

        bool start_array([[maybe_unused]] std::size_t elements) override;

        bool end_array() override;

        bool parse_error(
            [[maybe_unused]] std::size_t position, [[maybe_unused]] const std::string& last_token,
            [[maybe_unused]] const nlohmann::detail::exception& ex) override;

        std::string float_as_string;
    };


    bool
    my_json_sax::binary([[maybe_unused]] binary_t& val)
    {
        return true;
    }

    bool
    my_json_sax::null()
    {
        return true;
    }

    bool
    my_json_sax::boolean([[maybe_unused]] bool val)
    {
        return true;
    }

    bool
    my_json_sax::number_integer([[maybe_unused]] number_integer_t val)
    {
        return true;
    }

    bool
    my_json_sax::number_unsigned([[maybe_unused]] number_unsigned_t val)
    {
        return true;
    }

    bool
    my_json_sax::number_float([[maybe_unused]] number_float_t val, const string_t& s)
    {
        this->float_as_string = s;
        return true;
    }

    bool
    my_json_sax::string([[maybe_unused]] string_t& val)
    {
        return true;
    }

    bool
    my_json_sax::start_object([[maybe_unused]] std::size_t elements)
    {
        return true;
    }

    bool
    my_json_sax::key([[maybe_unused]] string_t& val)
    {
        return true;
    }

    bool
    my_json_sax::end_object()
    {
        return true;
    }

    bool
    my_json_sax::start_array([[maybe_unused]] std::size_t elements)
    {
        return true;
    }

    bool
    my_json_sax::end_array()
    {
        return true;
    }

    bool
    my_json_sax::parse_error(
        [[maybe_unused]] std::size_t position, [[maybe_unused]] const std::string& last_token, [[maybe_unused]] const nlohmann::detail::exception& ex)
    {
        return false;
    }
} // namespace atomic_dex::utils::details