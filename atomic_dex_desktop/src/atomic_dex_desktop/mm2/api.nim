##! Standard Import
import asyncdispatch
import httpclient
import json
import options
import sequtils
import tables

##! Dependencies Import
import jsonschema

##! Project Import
import ../coins/coins_cfg

## Local global module variable
let lgEndpoint = "http://127.0.0.1:7783"

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
export ElectrumAnswerSuccess
export ElectrumAnswerError
export `[]`
export `unsafeAccess`
export `create`

##! Type Declaration
type ElectrumAnswer = object
        success*: Option[ElectrumAnswerSuccess]
        error*:  Option[ElectrumAnswerError]

##! Local Functions
proc onProgressChanged(total, progress, speed: BiggestInt) =
  echo("Downloaded ", progress, " of ", total)
  echo("Current rate: ", speed div 1000, "kb/s")

proc templateRequest(jsonData: JsonNode, method_name: string) =
    jsonData["method"] = method_name.newJString
    jsonData["userpass"] = "atomic_dex_rpc_password".newJString

##! Global Function
proc rpcElectrum*(req: ElectrumRequestParams) : ElectrumAnswer =
    var client = newHttpClient()
    client.onProgressChanged = onProgressChanged
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })
    let jsonData = req.JsonNode
    templateRequest(jsonData, "electrum")
    let response = client.request(lgEndpoint, httpMethod = HttpPost, body = $jsonData)
    let json = parseJson(response.body)
    var res: ElectrumAnswer
    if json.isValid(ElectrumAnswerSuccess):
        res.success = some(ElectrumAnswerSuccess(json))
    elif json.isValid(ElectrumAnswerError):
        res.error = some(ElectrumAnswerError(json))
    return res

    