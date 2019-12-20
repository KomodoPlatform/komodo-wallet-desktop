import os, osproc
import marshal
import json
import hashes
import threadpool
import ./worker
import ../gui/gui
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

var mm2_cfg : MM2Config = MM2Config(gui: "MM2GUI", netid: 9999, userhome: os.getHomeDir(), passphrase: "thisIsTheNewProjectSeed2019##", rpc_password: "atomic_dex_mm2_passphrase")
var mm2_instance : Process = nil

proc set_passphrase*(passphrase: string) =
    mm2_cfg.passphrase = passphrase

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
        gui.set_gui_running(true)


proc enable_coin*(ticker: string) =
    echo is_ticker_present(ticker)
    var coin_info = coins_registry.cm_at(ticker.hash)
    #try:
    #    var coin_info = get_coin_info(ticker)
    #except std_out_of_range as ex:
    #    echo ex.what()
    if coin_info["currently_enabled"].getBool:
        return    
    #echo typeof(coin_info["electrum"])
    #var other = ElectrumServerParams[]
    #var req = create(ElectrumRequestParams, ticker, , true)
    

proc enable_default_coins() =
    var coins = get_active_coins()
    for _, v in coins:
        enable_coin(v["coin"].getStr)

proc init_process*()  =
    spawn mm2_init_thread()
    sync()
    enable_default_coins()
    launchMM2Worker()

proc close_process*() =
    if not mm2_instance.isNil:
        mm2_instance.terminate
        mm2_instance.close

    
