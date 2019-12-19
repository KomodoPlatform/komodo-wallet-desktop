import json
import sequtils
import options
import tables
import jsonschema
import ../utils/assets
import ../folly/hashmap

var coins_registry: ConcurrentReg[string, JsonNode]

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

template whenValid*(data, kind, body) =
  if data.isValid(kind):
    var data = kind(data)
    body

proc parse_cfg*() =
  let entire_file = readFile(get_assets_path() & "/config/coins.json")
  let jsonNode = parseJson(entire_file)
  for key in jsonNode.keys:
    if jsonNode[key].isValid(CoinConfigParams):
      assert(coins_registry.cm_insert_or_assign(key, jsonNode[key]).second == true, "should insert correctly")
    else:
      echo jsonNode[key], " is invalid"
  echo "Coins config correctly launched: ", coins_registry.cm_size()
