//
// Created by roman on 2/22/2021.
//

//! Cred
#include <wincred.h>

//! Linking
#pragma comment(lib, "Credui.lib")

//! Project
#include "antara/gaming/core/details/windows/security.authentification.hpp"

namespace antara::gaming::core::details
{
    void
    evaluate_authentication(const std::string& auth_reason, std::function<void(bool)> handler)
    {
        std::wstring wreason(auth_reason.begin(), auth_reason.end());
        std::size_t  max_nb_try = 3;
        CREDUI_INFOW credui     = {
            .cbSize = sizeof(CREDUI_INFOW), .hwndParent = nullptr, .pszMessageText = L"", .pszCaptionText = wreason.c_str(), .hbmBanner = nullptr};

        ULONG       auth_package    = 0;
        ULONG       out_cred_size   = 0;
        LPVOID      out_cred_buffer = nullptr;
        BOOL        save            = false;
        DWORD       err             = 0;
        std::size_t current_nb_try  = 0;
        bool        need_to_re_ask  = false;

        do {
            current_nb_try++;

            if (CredUIPromptForWindowsCredentialsW(&credui, err, &auth_package, nullptr, 0, &out_cred_buffer, &out_cred_size, &save, CREDUIWIN_ENUMERATE_ADMINS)

                != ERROR_SUCCESS)
            {
                handler(false);
                return;
            }


            ULONG        cch_username   = 0;
            ULONG        cch_password   = 0;
            ULONG        cch_domain     = 0;
            ULONG        cch_need       = 0;
            ULONG        cch_allocated  = 0;
            static UCHAR guz            = 0;
            auto         stack          = (PWSTR)alloca(guz);
            PWSTR        sz_user_name   = nullptr;
            PWSTR        sz_password    = nullptr;
            PWSTR        sz_domain_name = nullptr;

            BOOL ret;

            do {
                cch_need = cch_username + cch_password + cch_domain;
                if (cch_allocated < cch_need)
                {
                    sz_user_name   = (PWSTR)alloca((cch_need - cch_allocated) * sizeof(WCHAR));
                    cch_allocated  = (ULONG)(stack - sz_user_name);
                    sz_password    = sz_user_name + cch_username;
                    sz_domain_name = sz_password + cch_password;
                }

                ret = CredUnPackAuthenticationBufferW(
                    CRED_PACK_PROTECTED_CREDENTIALS, out_cred_buffer, out_cred_size, sz_user_name, &cch_username, sz_domain_name, &cch_domain, sz_password,
                    &cch_password);

            } while (!ret && GetLastError() == ERROR_INSUFFICIENT_BUFFER);


            SecureZeroMemory(out_cred_buffer, out_cred_size);
            CoTaskMemFree(out_cred_buffer);

            HANDLE handle = nullptr;

            if (LogonUserW(sz_user_name, sz_domain_name, sz_password, LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT, &handle))
            {
                CloseHandle(handle);
                handler(true);
                return;
            }

            else
            {
                err            = ERROR_LOGON_FAILURE;
                need_to_re_ask = true;
            }


        } while (need_to_re_ask && (current_nb_try < max_nb_try));

        handler(false);
    }
} // namespace antara::gaming::core::details
