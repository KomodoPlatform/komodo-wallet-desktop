pragma Singleton
import QtQuick 2.10

QtObject {
    readonly property int width: 1280
    readonly property int height: 800
    readonly property FontLoader mySystemFont: FontLoader { source: "Rubik-Regular.ttf" }
    readonly property font font: Qt.font({
                                             family: mySystemFont.name,
                                             pixelSize: Qt.application.font.pixelSize
                                         })
    readonly property font largeFont: Qt.font({
                                                  family: mySystemFont.name,
                                                  pixelSize: Qt.application.font.pixelSize * 1.6
                                              })
    readonly property color backgroundColor: "#c2c2c2"

    readonly property int styleRadius: 12
    readonly property int styleItemPadding: 12
    readonly property int stylePaneTitleOffset: 6
    readonly property int styleTextSize: 16
}
