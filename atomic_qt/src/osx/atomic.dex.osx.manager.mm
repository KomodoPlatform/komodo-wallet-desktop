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

#import <AppKit/AppKit.h>
#include "atomic.dex.osx.manager.hpp"

void atomic_dex::mac_window_setup(long winid)
{
    NSView *nativeView = reinterpret_cast<NSView *>(winid);
    NSWindow* nativeWindow = [nativeView window];
    [nativeWindow setTitlebarAppearsTransparent:YES];
    NSColor *myColor = [NSColor colorWithCalibratedRed:0.12 green:0.16 blue:0.22 alpha:1.0f];
    [nativeWindow setBackgroundColor: myColor];
    [nativeWindow setTitleVisibility: static_cast<NSWindowTitleVisibility>(1)];
}
