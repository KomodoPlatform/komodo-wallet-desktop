pragma Singleton
import QtQuick 2.10

QtObject {
    readonly property FontLoader mySystemFont: FontLoader { source: "../../assets/fonts/Rubik-Regular.ttf" }
    readonly property font font: Qt.font({
                                             family: mySystemFont.name,
                                             pixelSize: Qt.application.font.pixelSize
                                         })

    readonly property int textSize: 16
    readonly property int rectangleCornerRadius: 12
    readonly property int itemPadding: 12
    readonly property int paneTitleOffset: 6

    readonly property string colorRed: "#DC0333"
}
