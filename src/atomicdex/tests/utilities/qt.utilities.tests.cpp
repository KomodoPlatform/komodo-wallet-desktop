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

#include "atomicdex/pch.hpp"

//! Deps
#include <doctest/doctest.h>

#include "atomicdex/utilities/qt.utilities.hpp"

TEST_CASE("qt_variant_list_to_qt_string_list")
{
    QVariantList variant_list;
    
    variant_list.append(QString{"one"});
    variant_list.append(QString{"two"});
    variant_list.append(QString{"three"});
    
    QStringList result = atomic_dex::qt_variant_list_to_qt_string_list(variant_list);
    
    CHECK(result.size() == 3);
    CHECK(result[0] == "one");
    CHECK(result[1] == "two");
    CHECK(result[2] == "three");
}