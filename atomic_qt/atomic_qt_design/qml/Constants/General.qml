pragma Singleton
import QtQuick 2.10

QtObject {
    readonly property int width: 1280
    readonly property int height: 800
    readonly property int minimumWidth: 960
    readonly property int minimumHeight: 600
    readonly property string assets_path: "../../assets/"
    readonly property string image_path: assets_path + "images/"

    readonly property int idx_dashboard_wallet: 0
    readonly property int idx_dashboard_exchange: 1
    readonly property int idx_dashboard_news: 2
    readonly property int idx_dashboard_dapps: 3
    readonly property int idx_dashboard_settings: 4

    readonly property int idx_exchange_trade: 0
    readonly property int idx_exchange_orders: 1
    readonly property int idx_exchange_history: 2
    readonly property int idx_exchange_orderbook: 3
}
