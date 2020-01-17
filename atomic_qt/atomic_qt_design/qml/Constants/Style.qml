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
    readonly property string colorOrange: "#F7931A"
    readonly property string colorGreen: "#2FEA8B"

    readonly property string colorWhite1: "#FFFFFF"
    readonly property string colorWhite2: "#F9F9F9"
    readonly property string colorWhite3: "#F0F0F0"
    readonly property string colorWhite4: "#C9C9C9"
    readonly property string colorWhite5: "#8E9293"

    readonly property string colorTheme1: "#3CC9BF"
    readonly property string colorTheme2: "#36A8AA"
    readonly property string colorTheme3: "#318795"
    readonly property string colorTheme4: "#2B6680"
    readonly property string colorTheme5: "#26456B"
    readonly property string colorTheme6: "#283547"
    readonly property string colorTheme7: "#1E2938"
}
