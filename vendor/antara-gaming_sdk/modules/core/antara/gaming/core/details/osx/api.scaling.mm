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

//#import <CoreGraphics/CoreGraphics.h>
//#import <NSGeometry.h>
//#import <AppKit/AppKit.h>

#include "antara/gaming/core/details/osx/api.scaling.hpp"

namespace antara::gaming::core::details
{
    bool is_high_dpi_capable()
    {
  /*      NSBundle *bundle = [NSBundle mainBundle];
        if (!bundle)
            return false;
        return bool([bundle objectForInfoDictionaryKey:@"NSHighResolutionCapable"]);*/
  return true;
    }

    std::pair<float, float> get_scaling_factor()
    {
        /*auto factor = static_cast<float>([[NSScreen mainScreen] backingScaleFactor]);
        return {factor, factor};*/
        return {0.0, 0.0};
    }
}