#pragma once

#include <string> //> std::string

namespace atomic_dex::github_api
{
    // GitHub repository release information.
    struct repository_release
    {
        std::string url;
        std::string assets_url;
        std::string name;
        std::string tag_name;
    };
}
