pragma Singleton
import QtQuick 2.10

QtObject {
    readonly property FontLoader mySystemFontThin: FontLoader { source: "../../assets/fonts/Montserrat-Thin.ttf" }
    readonly property FontLoader mySystemFontLight: FontLoader { source: "../../assets/fonts/Montserrat-Light.ttf" }
    readonly property FontLoader mySystemFont: FontLoader { source: "../../assets/fonts/Montserrat-Regular.ttf" }
    readonly property FontLoader mySystemFontMedium: FontLoader { source: "../../assets/fonts/Montserrat-Medium.ttf" }
    readonly property FontLoader mySystemFontSemiBold: FontLoader { source: "../../assets/fonts/Montserrat-SemiBold.ttf" }
    readonly property font font: Qt.font({
                                             family: mySystemFont.name,
                                             pixelSize: Qt.application.font.pixelSize
                                         })

    readonly property string listItemPrefix:  " ⚬   "
    readonly property string successCharacter:  "✓"
    readonly property string failureCharacter:  "✘"

    readonly property int materialElevation: 5

    readonly property int textSizeVerySmall1: 1
    readonly property int textSizeVerySmall2: 2
    readonly property int textSizeVerySmall3: 3
    readonly property int textSizeVerySmall4: 4
    readonly property int textSizeVerySmall5: 5
    readonly property int textSizeVerySmall6: 6
    readonly property int textSizeVerySmall7: 7
    readonly property int textSizeVerySmall8: 8
    readonly property int textSizeVerySmall9: 9
    readonly property int textSizeSmall: 10
    readonly property int textSizeSmall1: 11
    readonly property int textSizeSmall2: 12
    readonly property int textSizeSmall3: 13
    readonly property int textSizeSmall4: 14
    readonly property int textSizeSmall5: 15
    readonly property int textSize: 16
    readonly property int textSizeMid: 17
    readonly property int textSizeMid1: 18
    readonly property int textSizeMid2: 19
    readonly property int textSize1: 20
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
    readonly property int sidebarLineHeight: 43

    readonly property string colorRed: "#E938A4"
    readonly property string colorRed2: "#B1346B"
    readonly property string colorRed3: "#B1346B"
    readonly property string colorYellow: "#FFC305"
    readonly property string colorOrange: "#F7931A"
    readonly property string colorGreen: "#41EAD4"

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
    readonly property string colorTheme5: "#23273C"
    readonly property string colorTheme6: "#22263A"
    readonly property string colorTheme7: "#15182A"
    readonly property string colorTheme8: "#171A2C"
    readonly property string colorTheme9: "#0E1021"
    readonly property string colorThemeLine: "#1D1F23"
    readonly property string colorThemePassive: "#777F8C"
    readonly property string colorThemePassiveLight: "#CCCDD0"
    readonly property string colorThemeDark: "#26282C"
    readonly property string colorThemeDarkLight: "#78808D"

    readonly property string colorGradient1: colorTheme9
    readonly property string colorGradient2: colorTheme5
    readonly property string colorGradient3: "#24283D"
    readonly property string colorGradient4: "#0D0F21"
    readonly property string colorLineGradient1: "#2c2f3c"
    readonly property string colorLineGradient2: "#06070c"
    readonly property string colorLineGradient3: "#090910"
    readonly property string colorLineGradient4: "#24283b"
    readonly property string colorDropShadowLight: "#216975a4"
    readonly property string colorDropShadowLight2: "#606975a4"
    readonly property string colorDropShadowDark: "#FF050615"
    readonly property string colorBorder: "#23273B"
    readonly property string colorBorder2: "#1C1F32"

    readonly property string colorGradientLine1: "#00FFFFFF"
    readonly property string colorGradientLine2: "#0FFFFFFF"

    readonly property string colorSidebarIconHighlighted: "#2BBEF2"
    readonly property string colorSidebarHighlightGradient1: "#FF1B5E7D"
    readonly property string colorSidebarHighlightGradient2: "#001B5E7D"

    property string colorButtonDisabled: Style.colorTheme9
    property string colorButtonHovered: Style.colorTheme6
    property string colorButtonEnabled: Style.colorTheme8
    property string colorButtonTextDisabled: Style.colorWhite8
    property string colorButtonTextHovered: Style.colorWhite1
    property string colorButtonTextEnabled: Style.colorWhite1  // Style.colorThemePassive

    readonly property int modalTitleMargin: 10
    readonly property string modalValueColor: colorWhite4
}
