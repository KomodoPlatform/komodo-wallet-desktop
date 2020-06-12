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

    readonly property int rectangleCornerRadius: 11
    readonly property int itemPadding: 12
    readonly property int buttonSpacing: 12
    readonly property int rowSpacing: 12
    readonly property int iconTextMargin: 5
    readonly property int sidebarLineHeight: 44
    readonly property int scrollbarOffset: 5

    property bool dark_theme: false

    readonly property string colorRed: dark_theme ? "#E938A4" : "#E938A4"
    readonly property string colorRed2:  dark_theme ? "#b61477" : "#b61477"
    readonly property string colorRed3:  dark_theme ? "#41072a" : "#41072a"
    readonly property string colorYellow:  dark_theme ? "#FFC305" : "#FFC305"
    readonly property string colorOrange:  dark_theme ? "#F7931A" : "#F7931A"
    readonly property string colorBlue:  dark_theme ? "#3B78D1" : "#3B78D1"
    readonly property string colorGreen:  dark_theme ? "#41EAD4" : "#41EAD4"
    readonly property string colorGreen2:  dark_theme ? "#14bca6" : "#14bca6"
    readonly property string colorGreen3:  dark_theme ? "#07433b" : "#07433b"

    readonly property string colorWhite1:  dark_theme ? "#FFFFFF" : "#FFFFFF"
    readonly property string colorWhite2:  dark_theme ? "#F9F9F9" : "#F9F9F9"
    readonly property string colorWhite3:  dark_theme ? "#F0F0F0" : "#F0F0F0"
    readonly property string colorWhite4:  dark_theme ? "#C9C9C9" : "#C9C9C9"
    readonly property string colorWhite5:  dark_theme ? "#8E9293" : "#8E9293"
    readonly property string colorWhite6:  dark_theme ? "#777777" : "#777777"
    readonly property string colorWhite7:  dark_theme ? "#666666" : "#666666"
    readonly property string colorWhite8:  dark_theme ? "#555555" : "#555555"
    readonly property string colorWhite9:  dark_theme ? "#444444" : "#444444"
    readonly property string colorWhite10:  dark_theme ? "#333333" : "#333333"
    readonly property string colorWhite11:  dark_theme ? "#222222" : "#222222"
    readonly property string colorWhite12:  dark_theme ? "#111111" : "#111111"
    readonly property string colorWhite13:  dark_theme ? "#000000" : "#000000"

    readonly property string colorTheme0:  dark_theme ? "#41EAD4" : "#41EAD4"
    readonly property string colorTheme1:  dark_theme ? "#3CC9BF" : "#3CC9BF"
    readonly property string colorTheme2:  dark_theme ? "#36A8AA" : "#36A8AA"
    readonly property string colorTheme3:  dark_theme ? "#318795" : "#318795"
    readonly property string colorTheme4:  dark_theme ? "#2B6680" : "#2B6680"
    readonly property string colorTheme5:  dark_theme ? "#23273C" : "#23273C"
    readonly property string colorTheme6:  dark_theme ? "#22263A" : "#22263A"
    readonly property string colorTheme7:  dark_theme ? "#15182A" : "#15182A"
    readonly property string colorTheme8:  dark_theme ? "#171A2C" : "#171A2C"
    readonly property string colorTheme9:  dark_theme ? "#0E1021" : "#0E1021"
    readonly property string colorTheme10:  dark_theme ? "#2579E0" : "#2579E0"
    readonly property string colorTheme11:  dark_theme ? "#00A3FF" : "#00A3FF"
    readonly property string colorThemeLine:  dark_theme ? "#1D1F23" : "#1D1F23"
    readonly property string colorThemePassive:  dark_theme ? "#777F8C" : "#777F8C"
    readonly property string colorThemePassiveLight:  dark_theme ? "#CCCDD0" : "#CCCDD0"
    readonly property string colorThemeDark:  dark_theme ? "#26282C" : "#26282C"
    readonly property string colorThemeDark2:  dark_theme ? "#3C4150" : "#3C4150"
    readonly property string colorThemeDarkLight:  dark_theme ? "#78808D" : "#78808D"

    readonly property string colorGradient1:  dark_theme ? colorTheme9 : colorTheme9
    readonly property string colorGradient2:  dark_theme ? colorTheme5 : colorTheme5
    readonly property string colorGradient3:  dark_theme ? "#24283D" : "#24283D"
    readonly property string colorGradient4:  dark_theme ? "#0D0F21" : "#0D0F21"
    readonly property string colorLineGradient1:  dark_theme ? "#2c2f3c" : "#2c2f3c"
    readonly property string colorLineGradient2:  dark_theme ? "#06070c" : "#06070c"
    readonly property string colorLineGradient3:  dark_theme ? "#090910" : "#090910"
    readonly property string colorLineGradient4:  dark_theme ? "#24283b" : "#24283b"
    readonly property string colorDropShadowLight:  dark_theme ? "#216975a4" : "#216975a4"
    readonly property string colorDropShadowLight2:  dark_theme ? "#606975a4" : "#606975a4"
    readonly property string colorDropShadowDark:  dark_theme ? "#FF050615" : "#FF050615"
    readonly property string colorBorder:  dark_theme ? "#23273B" : "#23273B"
    readonly property string colorBorder2:  dark_theme ? "#1C1F32" : "#1C1F32"

    readonly property string colorGradientLine1:  dark_theme ? "#00FFFFFF" : "#00FFFFFF"
    readonly property string colorGradientLine2:  dark_theme ? "#0FFFFFFF" : "#0FFFFFFF"

    readonly property string colorWalletsHighlightGradient1:  dark_theme ? "#801B5E7D" : "#801B5E7D"
    readonly property string colorWalletsHighlightGradient2:  dark_theme ? "#001B5E7D" : "#001B5E7D"

    readonly property string colorScrollbar:  dark_theme ? "#202339" : "#202339"
    readonly property string colorScrollbarBackground:  dark_theme ? "#10121F" : "#10121F"
    readonly property string colorScrollbarGradient1:  dark_theme ? "#33395A" : "#33395A"
    readonly property string colorScrollbarGradient2:  dark_theme ? "#292D48" : "#292D48"

    readonly property string colorSidebarIconHighlighted:  dark_theme ? "#2BBEF2" : "#2BBEF2"
    readonly property string colorSidebarHighlightGradient1:  dark_theme ? "#FF1B5E7D" : "#FF1B5E7D"
    readonly property string colorSidebarHighlightGradient2:  dark_theme ? "#001B5E7D" : "#001B5E7D"

    readonly property string colorCoinListHighlightGradient1:  dark_theme ? "#002C2E40" : "#002C2E40"
    readonly property string colorCoinListHighlightGradient2:  dark_theme ? "#FF2C2E40" : "#FF2C2E40"

    readonly property string colorRectangleBorderGradient1:  dark_theme ? "#2A2F48" : "#2A2F48"
    readonly property string colorRectangleBorderGradient2:  dark_theme ? "#0D1021" : "#0D1021"

    readonly property string colorLineBasic:  dark_theme ? "#303344" : "#303344"

    property string colorButtonDisabled: Style.colorTheme9
    property string colorButtonHovered: Style.colorTheme6
    property string colorButtonEnabled: Style.colorTheme7
    property string colorButtonTextDisabled: Style.colorWhite8
    property string colorButtonTextHovered: Style.colorWhite1
    property string colorButtonTextEnabled: Style.colorWhite1  // Style.colorThemePassive
    property string colorPlaceholderText: Style.colorWhite9
    readonly property string colorText2: dark_theme ? "#79808C" : "#3C5368"

    property string colorButtonDangerDisabled: Style.colorRed3
    property string colorButtonDangerHovered: Style.colorRed
    property string colorButtonDangerEnabled: Style.colorRed2

    property string colorButtonPrimaryDisabled: Style.colorGreen3
    property string colorButtonPrimaryHovered: Style.colorGreen
    property string colorButtonPrimaryEnabled: Style.colorGreen2

    readonly property int modalTitleMargin: 10
    readonly property string modalValueColor: colorWhite4
}
