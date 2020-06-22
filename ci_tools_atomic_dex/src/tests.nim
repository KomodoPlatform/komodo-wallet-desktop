import os
import osproc

import build

when defined(windows):
    import generate

proc run_tests*(build_type: string, osx_sdk_path: string, compiler_path: string) =
     when defined(linux) or defined(osx):
        build_atomic_qt(build_type, osx_sdk_path, compiler_path)
     when defined(windows):
        # build first and then generate to scan for missing dll
        build_atomic_qt(build_type, osx_sdk_path, compiler_path)
    
     when defined(osx):
        echo os.getCurrentDir()
        os.setCurrentDir(os.getCurrentDir().joinPath("bin").joinPath("atomic_qt_tests.app").joinPath("Contents").joinPath("MacOS"))
        echo "Running AtomicDex Pro Unit tests"
        discard osproc.execCmd("./atomic_qt_tests --reporters=xml --out=atomic-dex-tests-result.xml -s")
        echo "Successfully Generated atomic-dex-tests-result.xml"
   
     when defined(linux):
        echo os.getCurrentDir()
        os.setCurrentDir(os.getCurrentDir().joinPath("bin").joinPath("AntaraAtomicDexTestsAppDir").joinPath("usr").joinPath("bin"))
        echo "Running AtomicDex Pro Unit tests"
        discard osproc.execCmd("./atomic_qt_tests --reporters=xml --out=atomic-dex-tests-result.xml -s")
        echo "Successfully Generated atomic-dex-tests-result.xml"
     
     when defined(windows):
        echo os.getCurrentDir()
        os.setCurrentDir(os.getCurrentDir().joinPath("bin"))
        echo "Running AtomicDex Pro Unit tests"
        discard osproc.execCmd(".\\atomic_qt_tests.exe --reporters=xml --out=atomic-dex-tests-result.xml -s")
        echo "Successfully Generated atomic-dex-tests-result.xml"
