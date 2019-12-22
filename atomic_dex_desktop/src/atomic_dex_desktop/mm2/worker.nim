##! STD Headers
import threadpool
import asyncdispatch
import os

import ./balance

proc allTasks30s() {.async.} =
    await sleepAsync(1)
    var asyncresults = newseq[Future[void]](1)
    asyncresults[0] = taskResfreshBalance()
    await all(asyncresults)

proc taskFoo() {.async.} =
    echo "taskFoo"

proc taskBar() {.async.} =
    echo "taskBar"

proc allTasks5s() {.async.} =
    await sleepAsync(1)
    echo "allTasks5s"

proc task30SecondsAsync() {.async.} =
    asyncCheck allTasks30s()
    await sleepAsync(5000)

proc task30Seconds() =
    while true:
        waitFor task30SecondsAsync()

proc task5SecondsAsync() {.async.} =
    asyncCheck allTasks5s()
    await sleepAsync(5000)

proc task5Seconds() =
    while true:
        waitFor task5SecondsAsync()

proc launchMM2Worker*() =   
    spawn task30Seconds()
    spawn task5Seconds()