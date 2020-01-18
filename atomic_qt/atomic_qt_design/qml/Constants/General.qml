pragma Singleton
import QtQuick 2.10

QtObject {
    readonly property int width: 1280
    readonly property int height: 800
    readonly property string assets_path: "../../assets/"
    readonly property string image_path: assets_path + "images/"

    readonly property int idx_dashboard_wallet: 0
    readonly property int idx_dashboard_dex: 1
    readonly property int idx_dashboard_news: 2
    readonly property int idx_dashboard_dapps: 3
    readonly property int idx_dashboard_settings: 4
}
