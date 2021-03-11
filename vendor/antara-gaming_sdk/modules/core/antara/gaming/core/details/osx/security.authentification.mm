#import <AppKit/AppKit.h>
#import <LocalAuthentication/LAContext.h>

//! Project
#include "antara/gaming/core/details/osx/security.authentification.hpp"

namespace antara::gaming::core::details
{
void evaluate_authentication(const std::string& auth_reason, std::function<void(bool)> handler)
{
    NSError* error = nullptr;
    NSString* _Nonnull localized_reason = [NSString stringWithCString:auth_reason.c_str()
                                                             encoding:[NSString defaultCStringEncoding]];
    LAContext* ctx = [[LAContext alloc] init];

    if ([ctx canEvaluatePolicy:LAPolicy::LAPolicyDeviceOwnerAuthentication error:&error] != 0)
    {
        [ctx evaluatePolicy:LAPolicy::LAPolicyDeviceOwnerAuthentication
            localizedReason:localized_reason
                      reply: ^(BOOL success, [[maybe_unused]] NSError* __nullable err)
                      {
                          if ((error != nullptr) || (success == 0))
                          {
                              handler(false);
                              return;
                          }

                          if (success != 0)
                          {
                              handler(true);
                              return;
                          }
                      }
        ];
    }
    else
    {
        handler(true);
    }
    [ctx release];
}
}