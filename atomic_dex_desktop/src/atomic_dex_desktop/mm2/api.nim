import json
import sequtils
import options
import tables
import jsonschema
import httpclient
import asyncdispatch
import ../coins/coins_cfg

let g_endpoint = "http://127.0.0.1:7783"


jsonSchema:
    ElectrumRequestParams:
        coin: string
        servers: ElectrumServerParams[]
        with_tx_history : bool
    ElectrumAnswerSuccess:
        address: string
        balance: string
        "result": string
    ElectrumAnswerError:
        error: string
        
export ElectrumRequestParams
export `[]`
export `create`
export ElectrumAnswerSuccess
export ElectrumAnswerError

type ElectrumAnswer = object
        success: Option[ElectrumAnswerSuccess]
        error:  Option[ElectrumAnswerError]

proc onProgressChanged(total, progress, speed: BiggestInt) =
  echo("Downloaded ", progress, " of ", total)
  echo("Current rate: ", speed div 1000, "kb/s")

proc templateRequest(jsonData: JsonNode, method_name: string) =
    echo $(%*method_name)
    jsonData["method"] = method_name.newJString
    jsonData["userpass"] = "atomic_dex_rpc_password".newJString

proc rpc_electrum*(req: ElectrumRequestParams) : ElectrumAnswer =
    var client = newHttpClient()
    client.onProgressChanged = onProgressChanged
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })
    let jsonData = req.JsonNode
    templateRequest(jsonData, "electrum")
    echo $jsonData
    let response = client.request(g_endpoint, httpMethod = HttpPost, body = $jsonData)
    let json = parseJson(response.body)
    var res: ElectrumAnswer
    if json.isValid(ElectrumAnswerSuccess):
        res.success = some(ElectrumAnswerSuccess(json))
    elif json.isValid(ElectrumAnswerError):
        res.error = some(ElectrumAnswerError(json))
    return res

    