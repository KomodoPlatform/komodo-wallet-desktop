import os

when defined(windows):
  {.passL: "-L" & os.getEnv("VCPKG_ROOT") & "/installed/x64-windows-static/lib -lfolly -lWs2_32 -lboost_thread-vc140-mt -ldouble-conversion -lglog -lgflags_static -lshlwapi -levent -ladvapi32".}
  {.passC: "-std=c++17 -I" & os.getEnv("VCPKG_ROOT") & "/installed/x64-windows-static/include".}

when defined(macosx):
  {.passL: "-L" & os.getEnv("VCPKG_ROOT") & "/installed/x64-osx/lib -lfolly -ldouble-conversion -lgflags -lglog".}
  {.passC: "-std=c++17 -I" & os.getEnv("VCPKG_ROOT") & "/installed/x64-osx/include".}

when defined(linux):
  {.passL: "-L" & os.getEnv("VCPKG_ROOT") & "/installed/x64-linux/lib -lfolly -pthread -ldouble-conversion -lglog -lgflags".}
  {.passC: "-std=c++17 -I" & os.getEnv("VCPKG_ROOT") & "/installed/x64-linux/include".}

const folly_header = "<folly/concurrency/ConcurrentHashMap.h>"

type
  ConcurrentReg*[K, V] {.importcpp"folly::ConcurrentHashMap", header: folly_header, byref.} = object
  ConcurrentRegIt*[K, V] {.importcpp"folly::ConcurrentHashMap<'0, '1>::const_iterator", header: folly_header, byref.} = object
  StdPair*[K, V] {.importcpp: "std::pair", header: "<utility>".} = object

##! Map
proc cm_insert_or_assign*[K, V](instance: ConcurrentReg[K, V], key: K, value: V): StdPair[ConcurrentRegIt[K, V], bool] {.importcpp: "#.insert_or_assign(#, #)", header: folly_header.}
proc cm_at*[K, V](instance: ConcurrentReg[K, V], key: K): V {.importcpp: "#.at(#)", header: folly_header.}
proc cm_begin*[K, V](instance: ConcurrentReg[K, V]): ConcurrentRegIt[K, V] {.importcpp: "#.begin()", header: folly_header.}
proc cm_end*[K, V](instance: ConcurrentReg[K, V]): ConcurrentRegIt[K, V] {.importcpp: "#.end()", header: folly_header.}
proc cm_size*[K, V](instance: ConcurrentReg[K, V]): int {.importcpp: "#.size()", header: folly_header.}

##! Iterator
proc `*`*[K, V](instance: ConcurrentRegIt[K, V]): StdPair[K, V] {.importcpp: "*#".}
proc `++`*[K, V](instance: ConcurrentRegIt[K, V]) {.importcpp: "++#".}
proc `!=`*[K, V](lhs: ConcurrentRegIt[K, V], rhs: ConcurrentRegIt[K, V]): bool {.importcpp: "# != #".}

##! Map
proc first*[K, V](instance: StdPair[K, V]): K {.importcpp: "#.first", header: "<utility>".}
proc second*[K, V](instance: StdPair[K, V]): V {.importcpp: "#.second", header: "<utility>".}

##! Iterator Nim
iterator pairs*[K, V](range: ConcurrentReg[K, V]): (K, V) =
  var current = cast[ptr ConcurrentRegIt[K, V]](alloc0(sizeof(ConcurrentRegIt[K, V])))
  var last = cast[ptr ConcurrentRegIt[K, V]](alloc0(sizeof(ConcurrentRegIt[K, V])))
  current[] = range.cm_begin()
  last[] = range.cm_end()
  while current[] != last[]:
    var pr: StdPair[K, V]
    pr = *current[]
    ++current[]
    yield (pr.first(), pr.second())
