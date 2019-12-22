import os, osproc
import marshal
import json
import hashes
import threadpool
import options
import std/atomics
import ./worker
import ../utils/assets
import ../coins/coins_cfg
import ../folly/hashmap
import ./api

type
    MM2Config = object
        gui: string
        netid: int64
        userhome: string
        passphrase: string
        rpc_password: string

var mm2_cfg : MM2Config = MM2Config(gui: "MM2GUI", netid: 9999, userhome: os.getHomeDir(), passphrase: "thisIsTheNewProjectSeed2019##", rpc_password: "atomic_dex_rpc_password")
var mm2_fully_running*: Atomic[bool]
var mm2_instance : Process = nil

mm2_fully_running.store(false, moRelaxed)

proc set_passphrase*(passphrase: string) =
    mm2_cfg.passphrase = passphrase


proc enable_coin*(ticker: string) =
    {.gcsafe.}:
        var coin_info = get_coin_info(ticker)
        if coin_info["currently_enabled"].getBool:
            return
        var res: seq[ElectrumServerParams]
        for keys in coin_info["electrum"]:
            res.add(ElectrumServerParams(keys))
        var req = create(ElectrumRequestParams, ticker, res, true)
        var answer = rpc_electrum(req)
        if answer.error.isSome:
            echo answer.error.get()["error"].getStr
        else:
            var current : CoinConfigParams
            deepCopy(current, coin_info)
            current.JsonNode["currently_enabled"] = newJBool(true)
            current.JsonNode["active"] = newJBool(true)
            update_coin_info(ticker, coin_info, current)
    

proc enable_default_coins() =
    var coins = get_active_coins()
    for _, v in coins:
        spawn enable_coin(v["coin"].getStr)
    sync()    

proc mm2_init_thread() =
    {.gcsafe.}:
        var tools_path = (get_assets_path() & "/tools/mm2").normalizedPath
        try: 
            mm2_instance = startProcess(command=tools_path & "/mm2", args=[$$mm2_cfg], env = nil, options={poParentStreams}, workingDir=tools_path)
        except OSError as e:
            echo "Got exception OSError with message ", e.msg
        finally:
            echo "Fine."
        sleep(2000)
        mm2_fully_running.store(true)
        enable_default_coins()
        launchMM2Worker()

proc init_process*()  =
    spawn mm2_init_thread()

proc close_process*() =
    if not mm2_instance.isNil:
        mm2_instance.terminate
        mm2_instance.close

    
