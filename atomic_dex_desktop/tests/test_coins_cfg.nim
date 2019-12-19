import unittest
import options
import json
import jsonschema
import atomic_dex_desktop/coins/coins_cfg

echo "salut"

let jsonNode = parseJson("""{"electrum": [
    {
      "url": "electrum3.cipig.net:10000"
    },
    {
      "url": "electrum2.cipig.net:10000"
    },
    {
      "url": "electrum1.cipig.net:10000"
    }
  ]}""")