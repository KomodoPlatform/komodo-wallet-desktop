#include "utilities/global.utilities.hpp"

namespace atomic_dex
{
    inline fs::path get_appdata_folder()
    {
        return utils::get_atomic_dex_data_folder();
    }

    inline fs::path get_themes_folder()
    {
        return utils::get_themes_path();
    }

    inline fs::path get_theme_folder(std::string theme_name)
    {
        return utils::get_themes_path() / theme_name;
    }
}