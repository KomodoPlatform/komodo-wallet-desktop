import json
import options
import jsonschema

type
    ElectrumServer = object
        url: string 
    CoinConfig* = object
        ticker: string
        name: string
        electrum_urls: ElectrumServer
        currently_enabled: bool
        active: bool
        coinpaprika_id: bool
        is_erc_20: bool
        explorer_url: seq[string]


jsonSchema:
    ElectrumServerParams:
        url: string
        protocol ?: string
        disable_cert_verification ?: bool


when isMainModule:
    import unittest
    var schema = create(ElectrumServerParams, "salut", none(string), none(bool))
    check schema.JsonNode.isValid(ElectrumServerParams) == true
    echo "Oui"

    var jsonNode = parseJson("""
        {
        "url": "electrum3.cipig.net:10000"
        }""")

    check jsonNode.isValid(ElectrumServerParams) == true

    jsonNode = parseJson("""
        {
        "foo": "electrum3.cipig.net:10000"
        }""")

    check jsonNode.isValid(ElectrumServerParams) == false

