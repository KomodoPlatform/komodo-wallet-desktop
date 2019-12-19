import json
import sequtils
import options
import jsonschema

type
    ElectrumServer = object
        url: string
        protocol: Option[string]
        disable_cert_verification: Option[bool]
    CoinConfig* = object
        ticker: string
        name: string
        electrum_urls: seq[ElectrumServer]
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
    CoinConfigParams:
        ticker: string
        name: string
        electrum_urls: ElectrumServerParams[]
        currently_enabled: bool
        active: bool
        coinpaprika_id: bool
        is_erc_20: bool
        explorer_url: string[]