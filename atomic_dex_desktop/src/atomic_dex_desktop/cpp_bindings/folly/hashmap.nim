##! Standard Import
import os

##! Project Import
import ../std/pair

##! Compile time instructions
when defined(windows):
  {.passL: "-L" & os.getEnv("VCPKG_ROOT") & "/installed/x64-windows-static/lib -lfolly -lWs2_32 -lboost_thread-vc140-mt -ldouble-conversion -lglog -lgflags_static -lshlwapi -levent -ladvapi32".}
  {.passC: "-std=c++17 -DGLOG_NO_ABBREVIATED_SEVERITIES -DNOMINMAX -I" & os.getEnv("VCPKG_ROOT") & "/installed/x64-windows-static/include".}

when defined(macosx):
  {.passL: "-L" & os.getEnv("VCPKG_ROOT") & "/installed/x64-osx/lib -lfolly -ldouble-conversion -lgflags -lglog".}
  {.passC: "-std=c++17 -I" & os.getEnv("VCPKG_ROOT") & "/installed/x64-osx/include".}
  when defined(tsanitizer):
    {.emit: """
    #include <folly/SharedMutex.h>
    namespace folly
    {
        // Explicitly instantiate SharedMutex here:
        template class SharedMutexImpl<true>;
        template class SharedMutexImpl<false>;
    } 
""".}

when defined(linux):
  {.passL: "-L" & os.getEnv("VCPKG_ROOT") & "/installed/x64-linux/lib -lfolly -pthread -ldouble-conversion -lglog -lgflags".}
  {.passC: "-std=c++17 -I" & os.getEnv("VCPKG_ROOT") & "/installed/x64-linux/include".}

##! C++ Bindings
const follyHeader = "<folly/concurrency/ConcurrentHashMap.h>"

type
  ConcurrentReg*[K, V] {.importcpp"folly::ConcurrentHashMap", header: follyHeader, byref.} = object
  ConcurrentRegIt*[K, V] {.importcpp"folly::ConcurrentHashMap<'0, '1>::const_iterator", header: follyHeader, byref.} = object

##! Public Function binding
proc insertOrAssign*[K, V](instance: ConcurrentReg[K, V], key: K, value: V): StdPair[ConcurrentRegIt[K, V], bool] {.importcpp: "#.insert_or_assign(#, #)", header: follyHeader.}
proc assign*[K, V](instance: ConcurrentReg[K, V], key: K, value: V) {.importcpp: "#.assign(#, #)", header: follyHeader.}
proc assignIfEqual*[K, V](instance: ConcurrentReg[K, V], key: K, desired: V, value: V) {.importcpp: "#.assign_if_equal(#, #, #)", header: follyHeader.}
proc erase*[K, V](instance: ConcurrentReg[K, V], key: K) {.importcpp: "#.erase(#)", header: follyHeader.}
proc at*[K, V](instance: ConcurrentReg[K, V], key: K): V {.importcpp: "#.at(#)", header: follyHeader.}
proc find*[K, V](instance: ConcurrentReg[K, V], key: K): ConcurrentRegIt[K, V] {.importcpp: "#.find(#)", header: follyHeader.}
proc cBegin*[K, V](instance: ConcurrentReg[K, V]): ConcurrentRegIt[K, V] {.importcpp: "#.begin()", header: follyHeader.}
proc cEnd*[K, V](instance: ConcurrentReg[K, V]): ConcurrentRegIt[K, V] {.importcpp: "#.end()", header: follyHeader.}
proc size*[K, V](instance: ConcurrentReg[K, V]): int {.importcpp: "#.size()", header: follyHeader.}

##! Iterator
proc `*`*[K, V](instance: ConcurrentRegIt[K, V]): StdPair[K, V] {.importcpp: "*#"}
proc `$`*[K, V](instance: ConcurrentRegIt[K, V]): ptr StdPair[K, V] {.importcpp: "std::addressof(*#)"}
proc `++`*[K, V](instance: ConcurrentRegIt[K, V]) {.importcpp: "++#".}
proc `!=`*[K, V](lhs: ConcurrentRegIt[K, V], rhs: ConcurrentRegIt[K, V]): bool {.importcpp: "# != #".}

##! Iterator Nim
iterator pairs*[K, V](range: ConcurrentReg[K, V]): (K, V) =
  var current = cast[ptr ConcurrentRegIt[K, V]](alloc0(sizeof(ConcurrentRegIt[K, V])))
  var last = cast[ptr ConcurrentRegIt[K, V]](alloc0(sizeof(ConcurrentRegIt[K, V])))
  current[] = range.cBegin()
  last[] = range.cEnd()
  while current[] != last[]:
    var pr: StdPair[K, V]
    var f: K
    var s: V
    pr = *current[]
    deepCopy(f, pr.first())
    deepCopy(s, pr.second())
    ++current[]
    yield (f, s)
  dealloc(current)
  dealloc(last)