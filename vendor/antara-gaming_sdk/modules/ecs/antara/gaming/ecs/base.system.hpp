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
#include <string> ///< std::string

//! Dependencies Headers
#include <entt/entity/registry.hpp>   ///< entt::registry
#include <entt/signal/dispatcher.hpp> ///< entt::dispatcher

//! SDK Headers
#include "antara/gaming/ecs/system.type.hpp" ///< ecs::system_type;

namespace antara::gaming::ecs
{
    class base_system
    {
      public:
        //! Constructors
        base_system(entt::registry& entity_registry, bool im_a_plugin_system = false) ;

        //! Destructor
        virtual ~base_system()  = default;

        //! Pure virtual functions
        virtual void update()  = 0;

        virtual void post_update()  {};

        [[nodiscard]] virtual std::string get_name() const  = 0;

        [[nodiscard]] virtual system_type get_system_type_rtti() const  = 0;


        /**
         * \note This function marks the system, it will be destroyed in the next turn of the game loop by the system_manager.
         */
        void mark() ;

        /**
         * \note This function unmark the system, allows the prevention of a destruction in the next turn of the game loop by the system_manager.
         */
        void unmark() ;

        /**
         * \note This function tell you if a system is marked or no.
         * \return true if the system is marked, false otherwise
         */
        [[nodiscard]] bool is_marked() const ;

        /**
         * \note This function enable a system.
         * \note by default a system is enabled.
         */
        void enable() ;

        /**
         * \note This function disable a system.
         */
        void disable() ;

        /**
         * \note This function tell you if a system is enable or no.
         */
        [[nodiscard]] bool is_enabled() const ;

        /**
         * \note This function defines the system as a plugin, and therefore will use more feature in runtime to work properly
         */
        void im_a_plugin() ;

        /**
         * \note This function tell you if a system is a plugin or no
         * \return true if the system is a plugin, false otherwise
         */
        [[nodiscard]] bool is_a_plugin() const ;

        /**
         * \note This function retrieve a user data previously set by set_user_data
         * \note by default a user_data is a void pointer equal to nullptr.
         * \return user data of a system
         */
        void* get_user_data() ;

        /**
         * \note This function set a user data for this system
         * \note This function is very useful to transfer (with get_user_data) data between plugins since they are base_class.
         * \note This function will call on_set_user_data callback at the epilogue, by default on_set_user_data is empty and you need
         * to override it if you need it.
         * \note user should be aware here, that's manipulating void pointer is as your own risk.
         * \param data a void pointer representing the user data
         */
        void set_user_data(void* data) ;

      protected:
        //! Protected data members
        entt::registry&   entity_registry_;
        entt::dispatcher& dispatcher_;
        void*             user_data_{nullptr};

      private:
        //! Private data members
        bool is_plugin_{false};
        bool marked_{false};
        bool enabled_{true};
    };
} // namespace antara::gaming::ecs