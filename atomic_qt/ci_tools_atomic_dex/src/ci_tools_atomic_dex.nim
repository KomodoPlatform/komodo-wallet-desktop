import strutils ##! Official Package

import docopt ##! Dependencies Packages

import vcpkg ##! Local packages
import dependencies
import generate
import build

let doc = """
Atomic Dex CI Tools.

Usage:
  ci_tools_atomic_dex --install_vcpkg
  ci_tools_atomic_dex --install_dependencies
  ci_tools_atomic_dex build (release|debug)
  ci_tools_atomic_dex generate (release|debug)
  ci_tools_atomic_dex package (release|debug)
  ci_tools_atomic_dex --version
  ci_tools_atomic_dex (-h | --help)

Options:
  -h --help     Show this screen.
  --version     Show version.
"""

proc main() =
  let args = docopt(doc, version = "Atomic Dex CI Tools 0.0.1")
  vcpkg_prepare()
  if args["--install_vcpkg"]:
    install_vcpkg()
  elif args["--install_dependencies"]:
    download_packages()
  elif args["generate"]:
    if args["release"]:
      generate_solution("release")
    elif args["debug"]:
      generate_solution("debug")
  elif args["build"]:
    if args["release"]:
      build_atomic_qt("release")
    elif args["debug"]:
      build_atomic_qt("debug")

when isMainModule:
  main()
