import unittest
import strutils
import atomic_dex_desktop/folly/hashmap

type Toto = object
    foo: string

var x: ConcurrentReg[cint, Toto]
check(x.cm_insert_or_assign(1, Toto(foo: "Example")).second)
check(x.cm_size() == 1)
discard x.cm_insert_or_assign(2, Toto(foo: "Another One ?"))
check(x.cm_size() == 2)
discard x.cm_insert_or_assign(3, Toto(foo: "My Last example ?"))
check(x.cm_size() == 3)
for key, value in x:
  check(key != 0)
  check(value.foo.len > 0)
