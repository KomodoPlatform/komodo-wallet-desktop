import json
import sequtils
import options
import tables
import hashes
import jsonschema
import ../utils/assets
import ../folly/hashmap

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
var coins_registry: ConcurrentReg[int, CoinConfigParams]

template whenValid*(data, kind, body) =
  if data.isValid(kind):
    var data = kind(data)
    body

proc parse_cfg*() =
  let entire_file = readFile(get_assets_path() & "/config/coins.json")
  let jsonNode = parseJson(entire_file)
  for key in jsonNode.keys:
    if jsonNode[key].isValid(CoinConfigParams):
      var res = CoinConfigParams(jsonNode[key])
      assert(coins_registry.cm_insert_or_assign(key.hash,  res).second == true, "should insert correctly")
    else:
      echo jsonNode[key], " is invalid"
  echo "Coins config correctly launched: ", coins_registry.cm_size()

proc get_active_coins*() : seq[CoinConfigParams] =
    var destinations: seq[CoinConfigParams]
    for _, value in coins_registry:
        if value.JsonNode.isValid(CoinConfigParams) and value["active"].getBool:
            destinations.add(value)
    return destinations

proc get_enabled_coins*() : seq[CoinConfigParams] =
    var destinations: seq[CoinConfigParams]
    for key, value in coins_registry:
        if value["currently_enabled"].getBool:
            destinations.add(value)
    return destinations

proc get_enableable_coins*() : seq[CoinConfigParams] =
    var destinations: seq[CoinConfigParams]
    for key, value in coins_registry:
        if not value["currently_enabled"].getBool:
            destinations.add(value)
    return destinations

proc get_coin_info*(ticker: string): CoinConfigParams =
    var current : CoinConfigParams            
    var res = coins_registry.cm_at(ticker.hash)
    return res

proc update_coin_info*(ticker: string, current: CoinConfigParams, desired: CoinConfigParams) =
  coins_registry.cm_assign_if_equal(ticker.hash, current, desired)

proc is_ticker_present*(ticker: string): bool =
    return coins_registry.cm_find(ticker.hash) != coins_registry.cm_end()

proc dump_registry*() =
    for key, _ in coins_registry:
        echo "key: [", key, "]"