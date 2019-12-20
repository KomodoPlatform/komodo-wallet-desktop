import threadpool
import asyncdispatch
import os

proc allTasks30s() {.async.} =
    await sleepAsync(1)
    echo "allTasks30s"

proc taskFoo() {.async.} =
    echo "taskFoo"

proc taskBar() {.async.} =
    echo "taskBar"

proc allTasks5s() {.async.} =
    await sleepAsync(1)
    echo "allTasks5s"
    let foo = taskFoo()
    let bar = taskBar()
    await foo
    await bar

proc task30SecondsAsync() {.async.} =
    asyncCheck allTasks30s()
    await sleepAsync(30000)

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