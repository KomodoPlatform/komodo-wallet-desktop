pragma Singleton
import QtQuick 2.10

QtObject {
    readonly property int width: 1280
    readonly property int height: 800
    readonly property string assets_path: "../../assets/"
    readonly property string image_path: assets_path + "images/"
}
