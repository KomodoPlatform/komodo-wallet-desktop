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

proc processPost(data: JsonNode) : string =
    var client = newHttpClient()
    result = client.postContent(lgEndpoint, body = $data)

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
    BalanceRequestParams:
        coin: string
    BalanceAnswerSuccess:
        address: string
        balance: string
        locked_by_swaps: string
        coin: string
    BalanceAnswerError:
        error: string      

export ElectrumRequestParams
export ElectrumAnswerSuccess
export ElectrumAnswerError
export BalanceRequestParams
export BalanceAnswerSuccess
export `[]`
export `unsafeAccess`
export `create`

##! Type Declaration
type ElectrumAnswer = object
        success*: Option[ElectrumAnswerSuccess]
        error*:  Option[ElectrumAnswerError]

type BalanceAnswer = object
       success*: Option[BalanceAnswerSuccess]
       error*: Option[BalanceAnswerError]

##! Local Functions
proc onProgressChanged(total, progress, speed: BiggestInt) =
  echo("Downloaded ", progress, " of ", total)
  echo("Current rate: ", speed div 1000, "kb/s")

proc templateRequest(jsonData: JsonNode, method_name: string) =
    jsonData["method"] = method_name.newJString
    jsonData["userpass"] = "atomic_dex_rpc_password".newJString

##! Global Function
proc rpcElectrum*(req: ElectrumRequestParams) : ElectrumAnswer =
    let jsonData = req.JsonNode
    templateRequest(jsonData, "electrum")
    try:
        let json = processPost(jsonData).parseJson()
        if json.isValid(ElectrumAnswerSuccess):
            result.success = some(ElectrumAnswerSuccess(json))
        elif json.isValid(ElectrumAnswerError):
            result.error = some(ElectrumAnswerError(json))
    except HttpRequestError as e:
        echo "Got exception HttpRequestError: ", e.msg
        result.error = some(ElectrumAnswerError(%*{"error": e.msg}))


proc rpcBalance*(req: BalanceRequestParams) : BalanceAnswer =
    let jsonData = req.JsonNode
    templateRequest(jsonData, "my_balance")
    try:
        let json = processPost(jsonData).parseJson()
        if json.isValid(BalanceAnswerSuccess):
            result.success = some(BalanceAnswerSuccess(json))
        elif json.isValid(BalanceAnswerError):
            result.error = some(BalanceAnswerError(json))
    except HttpRequestError as e:
        echo "Got exception HttpRequestError: ", e.msg
        result.error = some(BalanceAnswerError(%*{"error": e.msg}))