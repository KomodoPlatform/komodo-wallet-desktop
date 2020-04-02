pragma Singleton
import QtQuick 2.10

QtObject {
    readonly property FontLoader mySystemFont: FontLoader { source: "../../assets/fonts/Rubik-Regular.ttf" }
    readonly property font font: Qt.font({
                                             family: mySystemFont.name,
                                             pixelSize: Qt.application.font.pixelSize
                                         })

    readonly property string listItemPrefix:  " ⚬   "

    readonly property int materialElevation: 1

    readonly property int textSizeSmall: 10
    readonly property int textSizeSmall1: 11
    readonly property int textSizeSmall2: 12
    readonly property int textSizeSmall3: 13
    readonly property int textSizeSmall4: 14
    readonly property int textSizeSmall5: 15
    readonly property int textSize: 16
    readonly property int textSize2: 24
    readonly property int textSize3: 36
    readonly property int textSize4: 48
    readonly property int textSize5: 60
    readonly property int textSize6: 72
    readonly property int textSize7: 84
    readonly property int textSize8: 96
    readonly property int textSize9: 108
    readonly property int textSize10: 120
    readonly property int textSize11: 132
    readonly property int textSize12: 144

    readonly property int rectangleCornerRadius: 12
    readonly property int itemPadding: 12
    readonly property int paneTitleOffset: 6
    readonly property int iconTextMargin: 5

    readonly property string colorRed: "#DC0333"
    readonly property string colorRed2: "#891931"
    readonly property string colorYellow: "#FFC305"
    readonly property string colorOrange: "#F7931A"
    readonly property string colorGreen: "#2FEA8B"

    readonly property string colorWhite1: "#FFFFFF"
    readonly property string colorWhite2: "#F9F9F9"
    readonly property string colorWhite3: "#F0F0F0"
    readonly property string colorWhite4: "#C9C9C9"
    readonly property string colorWhite5: "#8E9293"
    readonly property string colorWhite6: "#777777"
    readonly property string colorWhite7: "#666666"
    readonly property string colorWhite8: "#555555"
    readonly property string colorWhite9: "#444444"
    readonly property string colorWhite10: "#333333"
    readonly property string colorWhite11: "#222222"
    readonly property string colorWhite12: "#111111"
    readonly property string colorWhite13: "#000000"

    readonly property string colorTheme0: "#41EAD4"
    readonly property string colorTheme1: "#3CC9BF"
    readonly property string colorTheme2: "#36A8AA"
    readonly property string colorTheme3: "#318795"
    readonly property string colorTheme4: "#2B6680"
    readonly property string colorTheme5: "#3a4c66"
    readonly property string colorTheme6: "#283547"
    readonly property string colorTheme7: "#232F40"
    readonly property string colorTheme8: "#1E2938"

    readonly property int modalTitleMargin: 10
    readonly property string modalValueColor: Style.colorWhite4
}
