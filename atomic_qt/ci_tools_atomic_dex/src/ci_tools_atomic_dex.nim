import strutils ##! Official Package

import docopt ##! Dependencies Packages

import vcpkg ##! Local packages

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
  if args["--install_vcpkg"]:
    install_vcpkg()

when isMainModule:
  main()
