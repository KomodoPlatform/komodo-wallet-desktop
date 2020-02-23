import osproc

import vcpkg
import generate

proc build_atomic_qt*(config_type: string) =
    generate_solution(config_type)
    let cmd_line = "cmake --build . --config " & config_type
    discard osproc.execCmd(cmd_line)