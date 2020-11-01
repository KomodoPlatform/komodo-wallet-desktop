#if defined(_WIN32) || defined(WIN32)
    #include <windows.h>
    #include <stdlib.h>
#endif

#include "atomicdex/app.entry.hpp"

#if defined(WINDOWS_RELEASE_MAIN)
INT WINAPI
WinMain([[maybe_unused]] HINSTANCE hInst, HINSTANCE, [[maybe_unused]] LPSTR strCmdLine, INT)
#else
int
main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[])
#endif
{    
#if defined(WINDOWS_RELEASE_MAIN)
    int    argc = __argc;
    char** argv = __argv;
#endif

    //! run app
    int res = atomic_dex::run_app(argc, argv);
    return res;
}
