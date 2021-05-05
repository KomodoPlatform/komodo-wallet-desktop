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

//! STD
#include <string>

#include <Availability.h>
#include "manager.hpp"

#import <AppKit/AppKit.h>

static NSColor *colorFromRGB(unsigned char r, unsigned char g, unsigned char b)
{
    return [NSColor colorWithCalibratedRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0];
}

void atomic_dex::mac_window_setup(long winid, bool fullscreen)
{
    (void)winid;
    (void)fullscreen;
    @try {
    SPDLOG_INFO("mac_window_setup");
    NSView *nativeView = reinterpret_cast<NSView *>(winid);
    NSWindow* nativeWindow = [nativeView window];
    NSWindowStyleMask windowMask = NSWindowStyleMaskBorderless | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable;
    /*if (fullscreen) {
        windowMask |= NSWindowStyleMaskFullScreen;
    }*/
    [nativeWindow setStyleMask: windowMask];
    //[nativeWindow setTitlebarAppearsTransparent:YES];
    //NSColor *myColor = colorFromRGB(30, 41, 56);
    //[myColor set];
    //[nativeWindow setBackgroundColor: myColor];
    //[nativeWindow setTitleVisibility: static_cast<NSWindowTitleVisibility>(1)];
    }
    @catch (NSException *exception) {
        std::string reason = std::string([exception.reason UTF8String]);
        SPDLOG_ERROR("Exception caught in mac_window_setup {}", reason);
    }
}
