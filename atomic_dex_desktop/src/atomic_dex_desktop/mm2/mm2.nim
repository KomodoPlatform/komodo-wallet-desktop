import os, osproc
import json
import ../utils/assets

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

proc init_process*()  =
    var tools_path = (get_assets_path() & "/tools/mm2").normalizedPath
    let j = %*{"gui": mm2_cfg.gui, "netid": mm2_cfg.netid, "userhome": mm2_cfg.userhome, "passphrase": mm2_cfg.passphrase, "rpc_password": mm2_cfg.rpc_password}
    try: 
        mm2_instance = startProcess(command=tools_path & "/mm2", args=[pretty(j)], env = nil, options={poParentStreams}, workingDir=tools_path)
    except OSError:
        let msg = getCurrentExceptionMsg()
        echo "Got exception OSError with message ", msg
    finally:
        echo "Fine."

proc close_process*() =
    if not mm2_instance.isNil:
        mm2_instance.terminate
        mm2_instance.close
