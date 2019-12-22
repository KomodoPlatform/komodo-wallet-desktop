##! Standard Import
import algorithm
import hashes
import json
import options
import sequtils
import tables

##! Dependencies Import
import jsonschema

##! Project Import
import ../cpp_bindings/folly/hashmap
import ../cpp_bindings/std/pair
import ../utils/assets

##! Schema definitions
jsonSchema:
  ElectrumServerParams:
    url: string
    protocol ?: string
    disable_cert_verification ?: bool
  CoinConfigParams:
    coin: string
    asset ?: string
    name: string
    "type": string
    rpcport: int
    pubtype ?: int
    p2shtype ?: int
    wiftype ?: int
    txversion ?: int
    overwintered ?: int
    txfee ?: int
    mm2: int
    coingecko_id: string
    coinpaprika_id: string
    is_erc_20: bool
    electrum: ElectrumServerParams[]
    explorer_url: string[]
    active: bool
    currently_enabled: bool

export ElectrumServerParams
export CoinConfigParams
export `[]`
export `[]=`
export create
export unsafeAccess

##! Global variable
var coinsRegistry: ConcurrentReg[int, CoinConfigParams]

##! Public functions
proc parseCfg*() =
  let entireFile = readFile(getAssetsPath() & "/config/coins.json")
  let jsonNode = parseJson(entireFile)
  for key in jsonNode.keys:
    if jsonNode[key].isValid(CoinConfigParams):
      var res = CoinConfigParams(jsonNode[key])
      assert(coinsRegistry.insertOrAssign(key.hash,  res).second == true, "should insert correctly")
    else:
      echo jsonNode[key], " is invalid"
  echo "Coins config correctly launched: ", coinsRegistry.size()

proc getActiveCoins*() : seq[CoinConfigParams] =
    for _, value in coinsRegistry:
        if value.JsonNode.isValid(CoinConfigParams) and value["active"].getBool:
            result.add(value)
    result

proc getEnabledCoins*() : seq[CoinConfigParams] =
    for key, value in coinsRegistry:
        if value["currently_enabled"].getBool:
            result.add(value)
    result.sort(proc (a, b: CoinConfigParams): int = cmp(a["coin"].getStr, b["coin"].getStr))

proc getEnableableCoins*() : seq[CoinConfigParams] =
    for key, value in coinsRegistry:
        if not value["currently_enabled"].getBool:
            result.add(value)

proc getCoinInfo*(ticker: string): CoinConfigParams =   
    coinsRegistry.at(ticker.hash)

proc updateCoinInfo*(ticker: string, current: CoinConfigParams, desired: CoinConfigParams) =
  coinsRegistry.assignIfEqual(ticker.hash, current, desired)

proc isTickerPresent*(ticker: string): bool =
    coinsRegistry.find(ticker.hash) != coinsRegistry.cEnd()