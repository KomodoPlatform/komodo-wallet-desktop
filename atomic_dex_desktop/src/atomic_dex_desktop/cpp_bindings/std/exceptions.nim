##! std exceptions
type
  StdException* {.importcpp: "std::exception", header: "<exception>".} = object

type
  StdOutOfRange* {.importcpp: "std::out_of_range", header: "<stdexcept>".} = object

proc what*(s: StdException): cstring {.importcpp: "((char *)#.what())".}
proc what*(s: StdOutOfRange): cstring {.importcpp: "((char *)#.what())".}