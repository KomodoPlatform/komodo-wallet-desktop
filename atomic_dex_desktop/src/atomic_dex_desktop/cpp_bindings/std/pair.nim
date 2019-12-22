##! Std Pair
type StdPair*[K, V] {.importcpp: "std::pair", header: "<utility>", byref.} = object


proc first*[K, V](instance: StdPair[K, V]): K {.importcpp: "#.first", header: "<utility>".}
proc second*[K, V](instance: StdPair[K, V]): V {.importcpp: "#.second", header: "<utility>".}