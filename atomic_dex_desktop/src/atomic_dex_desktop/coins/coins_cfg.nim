import json
import sequtils
import options
import algorithm
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
    for _, value in coins_registry:
        if value.JsonNode.isValid(CoinConfigParams) and value["active"].getBool:
            result.add(value)
    result

proc get_enabled_coins*() : seq[CoinConfigParams] =
    for key, value in coins_registry:
        if value["currently_enabled"].getBool:
            result.add(value)
    result.sort(proc (a, b: CoinConfigParams): int = cmp(a["coin"].getStr, b["coin"].getStr))

proc get_enableable_coins*() : seq[CoinConfigParams] =
    for key, value in coins_registry:
        if not value["currently_enabled"].getBool:
            result.add(value)

proc get_coin_info*(ticker: string): CoinConfigParams =   
    coins_registry.cm_at(ticker.hash)

proc update_coin_info*(ticker: string, current: CoinConfigParams, desired: CoinConfigParams) =
  coins_registry.cm_assign_if_equal(ticker.hash, current, desired)

proc is_ticker_present*(ticker: string): bool =
    coins_registry.cm_find(ticker.hash) != coins_registry.cm_end()