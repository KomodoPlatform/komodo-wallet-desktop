import unittest
import options
import json
import jsonschema
include atomic_dex_desktop/coins/coins_cfg

var jsonNode = parseJson("""
    {
    "url": "electrum3.cipig.net:10000"
    }""")

check jsonNode.isValid(ElectrumServerParams) == true

template whenValid(data, kind, body) =
    if data.isValid(kind):
        var data = kind(data)
        body

whenValid(jsonNode, ElectrumServerParams):
    echo jsonNode["url"]

jsonNode = parseJson("""
    {
    "foo": "electrum3.cipig.net:10000"
    }""")

check jsonNode.isValid(ElectrumServerParams) == false

jsonNode = parseJson("""
    {
    "url": "electrum3.cipig.net:10000",
    "disable_cert_verification": true
    }""")

check jsonNode.isValid(ElectrumServerParams) == true
whenValid(jsonNode, ElectrumServerParams):
    echo jsonNode["url"]
    if jsonNode["disable_cert_verification"].isSome:
        echo jsonNode["disable_cert_verification"].get()