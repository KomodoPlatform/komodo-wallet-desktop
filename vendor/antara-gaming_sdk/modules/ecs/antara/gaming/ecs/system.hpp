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

//! C++ System Headers
#include <string>      ///< std::string
#include <type_traits> ///< std::is_same

//! SDK Headers
#include "antara/gaming/core/safe.refl.hpp"  ///< refl::reflect
#include "antara/gaming/ecs/base.system.hpp" ///< ecs::base_system
#include "antara/gaming/ecs/system.type.hpp" ///< ecs::st_system_logic[pre, post]_update

namespace antara::gaming::ecs
{
    template <typename TSystemDerived, typename TSystemType>
    class system : public base_system
    {
      public:
        //! Constructor
        template <typename... TArgs>
        explicit system(TArgs&&... args) ;

        //! Destructor
        ~system()  override;
        ;

        //! Pure virtual functions
        void update()  override = 0;

        //! Public static functions
        static std::string get_class_name() ;

        /**
         * \note this function allows you to retrieve the type of a system at compile time.
         * \return ​system_type of the derived system.
         */
        static constexpr system_type get_system_type() ;

        //! Public member functions
        /**
         * \note this function allows you to retrieve the type of a system at runtime.
         * \return ​system_type of the derived system
         */
        [[nodiscard]] system_type get_system_type_rtti() const  final;

        /**
         * \note this function allow you to get the name of the derived system
         * \return name of the derived system.
         */
        [[nodiscard]] std::string get_name() const  final;
    };
} // namespace antara::gaming::ecs

//! Implementation
#include "antara/gaming/ecs/system.ipp"

namespace antara::gaming::ecs
{
    //! Generate predefined template
    /**
     * \typedef logic_update_system
     * \note this typedef is a shortcut, and this is the one that should be used when you want to inherit as a logical system.
     * \example
     * \code
     * class system_implementation : public logic_update_system<system_implementation>
     * {
     *
     * };
     * \endcode
     */
    template <typename TSystemDerived>
    using logic_update_system = system<TSystemDerived, st_system_logic_update>;


    /**
     * \typedef pre_update_system
     * \note this typedef is a shortcut, and this is the one that should be used when you want to inherit as a pre update system.
     * \code
     * class system_implementation : public pre_update_system<system_implementation>
     * {
     *
     * };
     * \endcode
     */
    template <typename TSystemDerived>
    using pre_update_system = system<TSystemDerived, st_system_pre_update>;

    /**
     * \typedef post_update_system
     * \note this typedef is a shortcut, and this is the one that should be used when you want to inherit as a post update system.
     * \code
     * class system_implementation : public post_update_system<system_implementation>
     * {
     *
     * };
     * \endcode
     */
    template <typename TSystemDerived>
    using post_update_system = system<TSystemDerived, st_system_post_update>;
} // namespace antara::gaming::ecs
