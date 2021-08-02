//
// Created by roman on 2/22/2021.
//

#include <iostream>

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
        std::wstring wauth_reason{auth_reason.begin(), auth_reason.end()};
        std::size_t  max_nb_try = 3;
        CREDUI_INFOW credui     = {
            .cbSize = sizeof(CREDUI_INFOW), .hwndParent = nullptr, .pszMessageText = L"", .pszCaptionText = wauth_reason.c_str(), .hbmBanner = nullptr};

        ULONG       auth_package       = 0;
        ULONG       out_cred_buff_size = 0;
        LPVOID      out_cred_buffer    = nullptr;
        BOOL        save;
        DWORD       err                = 0;
        std::size_t current_nb_try     = 0;

        do {
            current_nb_try++;

            // Gets auth buffer
            if (CredUIPromptForWindowsCredentialsW(&credui, err, &auth_package, nullptr, 0, &out_cred_buffer, &out_cred_buff_size, &save, CREDUIWIN_ENUMERATE_CURRENT_USER)
                != ERROR_SUCCESS)
            {
                handler(false);
                return;
            }

            WCHAR username[CREDUI_MAX_USERNAME_LENGTH * sizeof(WCHAR)] = { 0 };
            WCHAR password[CREDUI_MAX_PASSWORD_LENGTH * sizeof(WCHAR)] = { 0 };
            DWORD username_length = CREDUI_MAX_USERNAME_LENGTH;
            DWORD password_length = CREDUI_MAX_PASSWORD_LENGTH;
            if (CredUnPackAuthenticationBufferW(CRED_PACK_PROTECTED_CREDENTIALS,
                                                out_cred_buffer, out_cred_buff_size,
                                                username, &username_length,
                                                NULL, NULL,
                                                password, &password_length) == TRUE)
            {
                SecureZeroMemory(out_cred_buffer, out_cred_buff_size);
                CoTaskMemFree(out_cred_buffer);

                HANDLE user_token{};

                // Removes domain from username
                std::wstring purified_username{username};
                if (auto pos = purified_username.find(L'\\'); pos != std::wstring::npos)
                {
                    purified_username.erase(0, pos + 1);
                }

                if (LogonUserW(purified_username.c_str(), NULL, password, LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT, &user_token) != 0)
                {
                    handler(true);
                    return;
                }

                auto last_err = GetLastError(); // 1327 (ERROR_ACCOUNT_RESTRICTION) should mean that the user has no password set. https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--1300-1699-
                std::cout << "Win32 LogonUserW error: " << last_err << std::endl;
                if (last_err == 1327)
                {
                    handler(true);
                    return;
                }
            }
            else
            {
                SecureZeroMemory(out_cred_buffer, out_cred_buff_size);
                CoTaskMemFree(out_cred_buffer);
            }
        } while (current_nb_try < max_nb_try);
        handler(false);
    }
} // namespace antara::gaming::core::details
