import strutils
import docopt

let doc = """
Atomic Dex CI Tools.

Usage:
  ci_tools_atomic_dex --install_vcpkg
  ci_tools_atomic_dex --install_dependencies
  ci_tools_atomic_dex build (release|debug)
  ci_tools_atomic_dex package (release|debug)
  ci_tools_atomic_dex --version
  ci_tools_atomic_dex (-h | --help)

Options:
  -h --help     Show this screen.
  --version     Show version.
"""

proc main() =
  let args = docopt(doc, version = "Atomic Dex CI Tools 0.0.1")
  echo args

when isMainModule:
  main()
