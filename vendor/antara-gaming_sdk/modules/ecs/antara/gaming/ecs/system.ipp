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

namespace antara::gaming::ecs
{
    template <typename TSystemDerived, typename TSystemType>
    template <typename... TArgs>
    system<TSystemDerived, TSystemType>::system(TArgs&&... args)  : base_system(std::forward<TArgs>(args)...)
    {
        //LOG_SCOPE_FUNCTION(INFO);
        //DVLOG_F(loguru::Verbosity_INFO, "creating system {}", this->get_name());
    }

    template <typename TSystemDerived, typename TSystemType>
    constexpr system_type
    system<TSystemDerived, TSystemType>::get_system_type() 
    {
        if constexpr (std::is_same_v<TSystemType, st_system_logic_update>)
            return system_type::logic_update;
        else if constexpr (std::is_same_v<TSystemType, st_system_pre_update>)
            return system_type::pre_update;
        else if constexpr (std::is_same_v<TSystemType, st_system_post_update>)
            return system_type::post_update;
        return system_type::size; // LCOV_EXCL_LINE
    }


    template <typename TSystemDerived, typename TSystemType>
    system_type
    system<TSystemDerived, TSystemType>::get_system_type_rtti() const 
    {
        return system::get_system_type();
    }

    template <typename TSystemDerived, typename TSystemType>
    std::string
    system<TSystemDerived, TSystemType>::get_name() const 
    {
        return system::get_class_name();
    }

    template <typename TSystemDerived, typename TSystemType>
    std::string
    system<TSystemDerived, TSystemType>::get_class_name() 
    {
        return refl::reflect<TSystemDerived>().name.str();
    }

    template <typename TSystemDerived, typename TSystemType>
    system<TSystemDerived, TSystemType>::~system() 
    {
        //LOG_SCOPE_FUNCTION(INFO);
        //DVLOG_F(loguru::Verbosity_INFO, "destroying system {}", this->get_name());
    }
} // namespace antara::gaming::ecs