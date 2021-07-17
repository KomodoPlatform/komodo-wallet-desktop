import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0

import Qaterial 1.0 as Qaterial

import "Screens"
import "Constants"
import "Components"
import "Dashboard"

DexRectangle
{
    id: app

    property string currentWalletName: ""
    property int page: current_page === 5 ? deepPage : current_page
    property int deepPage: 0
    property alias globalTheme: theme
    property string selected_wallet_name: ""
    property bool debug: debug_bar
    property bool debug_log: false
    property var notification_modal: notifications_modal
    property var notifications_list: current_page == idx_dashboard ? loader.item.notifications_list : []

    // Preload Chart
    signal pairChanged(string base, string rel)
    property var chart_component
    property var chart_object

    readonly property int idx_first_launch: 0
    readonly property int idx_recover_seed: 1
    readonly property int idx_new_user: 2
    readonly property int idx_login: 3
    readonly property int idx_initial_loading: 4
    readonly property int idx_dashboard: 5
    property int current_page
    property bool can_open_login: false
    property bool disconnected: false

    onCurrent_pageChanged: {
        if (window.logged !== undefined) {
            if (current_page === idx_dashboard) {
                window.logged = true
            } else {
                window.logged = false
            }
        }
    }

    function appendLog(text) {
        log_area.append(text)
    }

    function firstPage() {
        if (!API.app.first_run() && selected_wallet_name !== "") {
            if(app.disconnected) {
                app.disconnected = false
                can_open_login = false
            } else {
                can_open_login = true
            }
            
        } else {
            can_open_login = false
        }
        console.log("WALLET NAME::: %1, logSTATE: %2".arg(selected_wallet_name).arg(can_open_login))

        return idx_first_launch
    }

    function onDisconnect() {
        API.app.wallet_mgr.set_log_status(false);
        app.disconnected = true
        openFirstLaunch()
    }

    function openFirstLaunch(force = false, set_wallet_name = true) {
        if (set_wallet_name) selected_wallet_name = API.app.wallet_mgr.wallet_default_name

        General.initialized_orderbook_pair = false
        if (API.app.wallet_mgr.log_status()) {
            current_page = idx_dashboard
        } else {
            current_page = force ? idx_first_launch : firstPage()
        }
    }

    Shortcut {
        sequence: "F11"
        onActivated: window.showNormal()
    }
    Component {
        id: no_connection

        NoConnection {}
    }
    NotificationsModal {
        id: notifications_modal
    }

    Component {
        id: first_launch

        FirstLaunch {
            onClickedNewUser: () => {
                current_page = idx_new_user
            }
            onClickedRecoverSeed: () => {
                current_page = idx_recover_seed
            }
            onClickedWallet: () => {
                current_page = idx_login
            }
        }
    }

    Component {
        id: recover_seed

        RecoverSeed {
            onClickedBack: () => {
                can_open_login = false
                openFirstLaunch(true)
            }
            onPostConfirmSuccess: () => {
                openFirstLaunch(false, false)
            }
        }
    }

    Component {
        id: new_user

        NewUser {
            onClickedBack: () => {
                can_open_login = false
                openFirstLaunch(true)
            }
            onPostCreateSuccess: () => {
                openFirstLaunch(false, false)
            }
            Component.onCompleted: console.log("Initialized new user")
        }
    }

    Component {
        id: login

        Login {
            onClickedBack: () => {
                can_open_login = false
                openFirstLaunch(true)
            }
            onPostLoginSuccess: () => {
                current_page = idx_initial_loading
            }
            Component.onCompleted: console.log("Initialized login")
        }
    }

    Component {
        id: initial_loading

        InitialLoading {
            onLoaded: () => {
                current_page = idx_dashboard
            }
        }
    }


    Component {
        id: dashboard

        Dashboard {}
    }
    Component {
        id: dialogManager
        DexDialogManager {

        }  
    }
    


    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: {
            if (!API.app.internet_checker.internet_reacheable)
                return no_connection

            switch (current_page) {
                case idx_dashboard:
                    return dashboard
                case idx_first_launch:
                    return first_launch
                case idx_initial_loading:
                    return initial_loading
                case idx_login:
                    return login
                case idx_new_user:
                    return new_user
                case idx_recover_seed:
                    return recover_seed
                default:
                    return undefined
            }
        }
    }

    // Error Modal
    ModalLoader {
        id: error_log_modal
        sourceComponent: LogModal {}
    }

    function showError(title, content) {
        if (content === undefined || content === null) return
        error_log_modal.open()
        error_log_modal.item.header = title
        error_log_modal.item.field.text = content
    }

    // Toast
    ToastManager {
        id: toast
    }

    // Update Modal
    NewUpdateModal {
        id: new_update_modal
        visible: false
    }

    UpdateInvalidChecksum {
        id: update_invalid_checksum
        visible: false
    }

    // Fatal Error Modal
    FatalErrorModal {
        id: fatal_error_modal
        visible: false
    }

    // Recover funds result modal
    LogModal
    {
        id: recoverFundsResultModal

        visible: false

        header: qsTr("Recover Funds Result")

        onClosed: field.text = "{}"

        Connections // Catches signals from orders_model.
        {
            target: API.app.orders_mdl

            function onRecoverFundDataChanged()
            {
                if (!API.app.orders_mdl.recover_fund_busy)
                {
                    console.log(JSON.stringify(API.app.orders_mdl.recover_fund_data))
                    recoverFundsResultModal.field.text = General.prettifyJSON(API.app.orders_mdl.recover_fund_data)
                    recoverFundsResultModal.open()
                }
            }
        }
    }

    Item {
        id: debug_control
        property var splitViewState
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 110
        height: 20
        visible: app.debug
        Menu {
            id: contextMenu
            Action {
                text: "Display Normal"
                onTriggered: {
                    treeView.parent.visible = true
                    _statusView.visible = true
                    flow.parent.parent.visible = true
                    app.parent.width = app.parent.parent.width - treeView.width
                    app.parent.height = app.parent.parent.height
                    app.parent.parent.update()
                }
            }
            Action {
                text: "Show Full"
                onTriggered: {
                    app.parent.width = app.parent.parent.width - treeView.width
                    app.parent.height = app.parent.parent.height
                    treeView.parent.visible = false
                    _statusView.visible = false
                    flow.parent.parent.visible = false

                }
            }
            Action {
                text: "Show Minimum"
                onTriggered: {
                    app.parent.width = General.minimumWidth
                    app.parent.height = General.minimumHeight

                }
            }
            Action {
                text: "Show FullScreen"
                onTriggered: {
                    window.showFullScreen()

                }

            }
            Action {
                text: "Clean Cache"
                onTriggered: {
                    _statusView.children[0].contentItem.children[0].clear()
                }
            }
        }

        Rectangle {
            width: parent.width
            radius: 1
            height: 20
            color: Qaterial.Colors.blueGray600
        }

        Row {
            anchors.centerIn: parent
            spacing: 10
            anchors.bottomMargin: 5
            DefaultText {
                text: "%1x%2".arg(app.width).arg(app.height)
                color: 'white'
                font.pixelSize: 13
                layer.enabled: true
                DropShadow {
                    color: 'black'
                }
            }
            Qaterial.ColorIcon {
                source: Qaterial.Icons.tools
                iconSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }

        }
        DefaultMouseArea {
            anchors.fill: parent
            onClicked: {
                contextMenu.open()
            }
        }
    }

    Settings {
        id: atomic_settings2
        fileName: atomic_cfg_file
    }

    Settings {
        id: ui_font_settings
        property alias fontDensity: _font.fontDensity
        property alias fontFamily: _font.fontFamily
    }

    function loadTheme() {
        console.log(JSON.stringify(API.qt_utilities.get_themes_list()))
        atomic_settings2.sync()
        let current = atomic_settings2.value("CurrentTheme")
        console.log(current)
        load_theme(current.replace(".json", ""))
    }

    function showDialog(data) {
        let dialog = dialogManager.createObject(window, data)
        for(var i in data) {
            if(i.startsWith('on')) {
                eval('dialog.%1.connect(data[i])'.arg(i))
            }
        }
        dialog.open()
        return dialog
    }

    function showText(data) {
        return showDialog(data)
    }
    function getText(data) {
        data['getText'] = true
        return showText(data)
    }

    Component.onCompleted: {
        selected_wallet_name !== ""
        openFirstLaunch()
        loadTheme()
    }
    Timer {
        interval: 5000
        repeat: true
        running: false
        onTriggered: loadTheme()
    }
    Shortcut {
        sequence: "Ctrl+R"
        onActivated: loadTheme()
    }


    property
    var global_theme_property: ["primaryColor", "accentColor", "backgroundColor", "backgroundColorDeep", "dexBoxBackgroundColor", "surfaceColor", "barColor", "hightlightColor", "sideBarGradient1", "sideBarGradient2",
        "navigationSideBarButtonGradient1", "navigationSideBarButtonGradient2", "navigationSideBarButtonGradient3",
        "navigationSideBarButtonGradient4", "chartTradingLineColor", "chartTradingLineBackgroundColor", "foregroundColor",
        "colorSidebarDropShadow", "whiteblack", "colorThemeDarkLight", "greenColor", "redColor", "textSelectionColor", "textPlaceHolderColor", "textSelectedColor",
        "buttonColorDisabled", "buttonColorHovered", "buttonColorEnabled", "buttonColorTextDisabled", "buttonColorTextHovered", "buttonColorTextEnabled",
        "colorInnerShadowBottom", "colorInnerShadowTop", "innerShadowColor", "colorLineGradient1", "colorLineGradient2", "colorLineGradient3", "colorLineGradient4", "floatShadow1", "floatShadow2", "floatBoxShadowDark"
    ]

    function save_currentTheme(name) {
        let data = {}
        global_theme_property.forEach(function(e) {
            data[e] = eval("theme." + e).toString()
        })
        data["bigSidebarLogo"] = theme.bigSidebarLogo
        data["smallSidebarLogo"] = theme.smallSidebarLogo
        data["chartTheme"] = theme.chartTheme
        let r = API.qt_utilities.save_theme(name + ".json", data, true)
        console.log(r)
    }

    function load_theme(name) {
        let data = API.qt_utilities.load_theme(name)
        for (let i in data) {
            if (i.toString().indexOf("[int]") !== -1) {
                let real_i = i;
                i = i.replace("[int]", "")
                console.log("theme." + i.toString() + " = " + data[real_i] + "")
                eval("theme." + i.toString() + " = " + data[real_i])
            } else {
                console.log("theme." + i.toString() + " = '" + data[i] + "'")
                eval("theme." + i.toString() + " = '" + data[i] + "'")
            }
        }
        Qaterial.Style.accentColor = theme.accentColor
        console.log("END APPLY ".arg(name))
    }

    color: theme.surfaceColor
    radius: 0
    border.width: 0
    border.color: 'transparent'

    QtObject {
        id: theme


        // Font
        property alias textType: _font
        property string chartTheme: Style.dark_theme ? "dark" : "light"
        property color primaryColor: "#171A2C" //Qaterial.Colors.indigo900
        property color backgroundColor: Style.colorTheme7
        property color surfaceColor: Style.colorTheme8
        property color backgroundColorDeep: Style.colorTheme8
        property color dexBoxBackgroundColor: Style.colorTheme9

        property color hightlightColor: Style.colorTheme5
        property int sidebarShadowRadius: 32

        property color sideBarGradient1: Style.colorGradient1
        property color sideBarGradient2: Style.colorGradient2
        property real sideBarAnimationDuration: Style.animationDuration

        property color navigationSideBarButtonGradient1: Style.colorSidebarHighlightGradient1
        property color navigationSideBarButtonGradient2: Style.colorSidebarHighlightGradient2
        property color navigationSideBarButtonGradient3: Style.colorSidebarHighlightGradient3
        property color navigationSideBarButtonGradient4: Style.colorSidebarHighlightGradient4

        property color chartTradingLineColor: Style.colorTrendingLine
        property color chartTradingLineBackgroundColor: Style.colorTrendingUnderLine
        property color lineChartColor: theme.accentColor
        property color chartGridLineColor: Qt.rgba(255, 255, 255, 0.4)

        property color foregroundColor: Style.colorText

        // Button
        property color buttonColorDisabled: Style.colorButtonDisabled["default"]
        property color buttonColorHovered: Style.colorButtonHovered["default"]
        property color buttonColorEnabled: Style.colorButtonEnabled["default"]
        property color buttonColorTextDisabled: Style.colorButtonTextDisabled["default"]
        property color buttonColorTextHovered: Style.colorButtonTextHovered["default"]
        property color buttonColorTextEnabled: Style.colorButtonTextEnabled["default"]

        property color colorInnerShadowBottom: Style.colorRectangleBorderGradient1
        property color colorInnerShadowTop: Style.colorRectangleBorderGradient2

        property color colorSidebarDropShadow: Style.colorSidebarDropShadow

        property color accentColor: Style.colorTheme4

        property color barColor: Style.colorTheme5

        property color colorLineGradient1: Style.colorLineGradient1
        property color colorLineGradient2: Style.colorLineGradient2
        property color colorLineGradient3: Style.colorLineGradient3
        property color colorLineGradient4: Style.colorLineGradient4

        property color floatShadow1: Style.colorDropShadowLight
        property color floatShadow2: Style.colorDropShadowLight2
        property color floatBoxShadowDark: Style.colorDropShadowDark

        property color textSelectionColor: Style.colorSelection
        property color textPlaceHolderColor: Style.colorPlaceholderText
        property color textSelectedColor: Style.colorSelectedText
        property color innerShadowColor: Style.colorInnerShadow

        property color greenColor: Style.colorGreen
        property color redColor: Style.colorRed

        property color whiteblack: Style.colorWhite1
        property color colorThemeDarkLight: Style.colorThemeDarkLight


        property color rectangleBorderColor: Style.colorBorder
        property int rectangleRadius: Style.rectangleCornerRadius
        property string bigSidebarLogo: "dex-logo-sidebar.png"
        property string smallSidebarLogo: "dex-logo.png"

























        function setQaterialStyle() {
            Qaterial.Style.accentColorLight = Style.colorTheme4
            Qaterial.Style.accentColorDark = Style.colorTheme4
        }
        onDark_themeChanged: setQaterialStyle()


        readonly property string listItemPrefix: " ⚬   "
        readonly property string successCharacter: "✓"
        readonly property string failureCharacter: "✘"
        readonly property string warningCharacter: "⚠"

        readonly property int animationDuration: 125

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

        readonly property int rectangleCornerRadius: 7
        readonly property int itemPadding: 12
        readonly property int buttonSpacing: 12
        readonly property int rowSpacing: 12
        readonly property int rowSpacingSmall: 6
        readonly property int iconTextMargin: 5
        readonly property int sidebarLineHeight: 44
        readonly property double hoverLightMultiplier: 1.5
        readonly property double hoverOpacity: 0.6

        property bool dark_theme: true


        function applyOpacity(hex, opacity = "00") {
            return "#" + opacity + hex.substr(hex.length - 6)
        }

        function colorOnlyIf(condition, color) {
            return applyOpacity(color, condition ? "FF" : "00")
        }

        readonly property string colorQtThemeAccent: colorGreen
        readonly property string colorQtThemeForeground: colorWhite1
        readonly property string colorQtThemeBackground: colorTheme9

        readonly property string sidebar_atomicdex_logo: dark_theme ? "dex-logo-sidebar.png" : "dex-logo-sidebar-dark.png"
        readonly property string colorRed: dark_theme ? "#D13990" : "#9a1165" // Light is 15% darker than Red2, same with the green set
        readonly property string colorRed2: dark_theme ? "#b61477" : "#b61477"
        readonly property string colorRed3: dark_theme ? "#6d0c47" : "#D13990"
        readonly property string colorYellow: dark_theme ? "#FFC305" : "#FFC305"
        readonly property string colorOrange: dark_theme ? "#F7931A" : "#F7931A"
        readonly property string colorBlue: dark_theme ? "#3B78D1" : "#3B78D1"
        readonly property string colorGreen: dark_theme ? "#74FBEE" : "#109f8d"
        readonly property string colorGreen2: dark_theme ? "#14bca6" : "#14bca6"
        readonly property string colorGreen3: dark_theme ? "#07433b" : "#74FBEE"

        readonly property string colorWhite1: dark_theme ? "#FFFFFF" : "#000000"
        readonly property string colorWhite2: dark_theme ? "#F9F9F9" : "#111111"
        readonly property string colorWhite3: dark_theme ? "#F0F0F0" : "#222222"
        readonly property string colorWhite4: dark_theme ? "#C9C9C9" : "#333333"
        readonly property string colorWhite5: dark_theme ? "#8E9293" : "#444444"
        readonly property string colorWhite6: dark_theme ? "#777777" : "#555555"
        readonly property string colorWhite7: dark_theme ? "#666666" : "#666666"
        readonly property string colorWhite8: dark_theme ? "#555555" : "#777777"
        readonly property string colorWhite9: dark_theme ? "#444444" : "#8E9293"
        readonly property string colorWhite10: dark_theme ? "#333333" : "#C9C9C9"
        readonly property string colorWhite11: dark_theme ? "#222222" : "#F0F0F0"
        readonly property string colorWhite12: dark_theme ? "#111111" : "#F9F9F9"
        readonly property string colorWhite13: dark_theme ? "#000000" : "#FFFFFF"

        readonly property string colorTheme1: dark_theme ? "#3CC9BF" : "#3CC9BF"
        readonly property string colorTheme2: dark_theme ? "#36A8AA" : "#36A8AA"
        readonly property string colorTheme3: dark_theme ? "#318795" : "#318795"
        readonly property string colorTheme4: dark_theme ? "#2B6680" : "#2B6680"
        readonly property string colorTheme5: dark_theme ? "#23273C" : "#ececf2"
        readonly property string colorTheme6: dark_theme ? "#22263A" : "#efeff5"
        readonly property string colorTheme7: dark_theme ? "#15182A" : "#f2f2f7"
        readonly property string colorTheme8: dark_theme ? "#171A2C" : "#f6f6f9"
        readonly property string colorTheme9: dark_theme ? "#0E1021" : "#F9F9FB"
        readonly property string colorTheme99: dark_theme ? "#2A2C3B" : "#F9F9FB"

        readonly property string colorTheme10: dark_theme ? "#2579E0" : "#2579E0"
        readonly property string colorTheme11: dark_theme ? "#00A3FF" : "#00A3FF"
        readonly property string colorThemeLine: dark_theme ? "#1D1F23" : "#1D1F23"
        readonly property string colorThemePassive: dark_theme ? "#777F8C" : "#777F8C"
        readonly property string colorThemePassiveLight: dark_theme ? "#CCCDD0" : "#CCCDD0"
        readonly property string colorThemeDark: dark_theme ? "#26282C" : "#26282C"
        readonly property string colorThemeDark2: dark_theme ? "#3C4150" : "#E6E8ED"
        readonly property string colorThemeDark3: dark_theme ? "#78808D" : "#78808D"
        //readonly property string colorThemeDarkLight:  dark_theme ? "#78808D" : "#456078"

        readonly property string colorRectangle: dark_theme ? colorTheme7 : colorTheme7
        readonly property string colorInnerBackground: dark_theme ? colorTheme7 : colorTheme7

        readonly property string colorGradient1: dark_theme ? colorTheme9 : colorTheme9
        readonly property string colorGradient2: dark_theme ? colorTheme5 : colorTheme5
        readonly property string colorGradient3: dark_theme ? "#24283D" : "#24283D"
        readonly property string colorGradient4: dark_theme ? "#0D0F21" : "#0D0F21"
        //readonly property string colorLineGradient1:  dark_theme ? "#2c2f3c" : "#EEF1F7"
        //readonly property string colorLineGradient2:  dark_theme ? "#06070c" : "#DCE1E8"
        //readonly property string colorLineGradient3:  dark_theme ? "#090910" : "#EEF1F7"
        //readonly property string colorLineGradient4:  dark_theme ? "#24283b" : "#DCE1E8"
        readonly property string colorDropShadowLight: dark_theme ? "#216975a4" : "#21FFFFFF"
        readonly property string colorDropShadowLight2: dark_theme ? "#606975a4" : "#60FFFFFF"
        readonly property string colorDropShadowDark: dark_theme ? "#FF050615" : "#BECDE2"
        readonly property string colorBorder: dark_theme ? "#23273B" : "#DAE1EC"
        readonly property string colorBorder2: dark_theme ? "#1C1F32" : "#DAE1EC"

        readonly property string colorInnerShadow: dark_theme ? "#A0000000" : "#BECDE2"

        readonly property string colorGradientLine1: dark_theme ? "#00FFFFFF" : "#00CFD4DB"
        readonly property string colorGradientLine2: dark_theme ? "#0FFFFFFF" : "#FFCFD4DB"

        readonly property string colorWalletsHighlightGradient: dark_theme ? "#1B5E7D" : "#1B5E7D"
        readonly property string colorWalletsSidebarDropShadow: dark_theme ? "#B0000000" : "#BECDE2"

        readonly property string colorScrollbar: dark_theme ? "#202339" : "#C4CCDA"
        readonly property string colorScrollbarBackground: dark_theme ? "#10121F" : "#EFF1F6"
        readonly property string colorScrollbarGradient1: dark_theme ? "#33395A" : "#C4CCDA"
        readonly property string colorScrollbarGradient2: dark_theme ? "#292D48" : "#C4CCDA"

        readonly property string colorSidebarIconHighlighted: dark_theme ? "#2BBEF2" : "#FFFFFF"
        readonly property string colorSidebarHighlightGradient1: dark_theme ? "#FF1B5E7D" : "#8b95ed"
        readonly property string colorSidebarHighlightGradient2: dark_theme ? "#BA1B5E7D" : "#AD7faaf0"
        readonly property string colorSidebarHighlightGradient3: dark_theme ? "#5F1B5E7D" : "#A06dc9f3"
        readonly property string colorSidebarHighlightGradient4: dark_theme ? "#001B5E7D" : "#006bcef4"
        //readonly property string colorSidebarDropShadow:  dark_theme ? "#90000000" : "#BECDE2"
        readonly property string colorSidebarSelectedText: dark_theme ? "#FFFFFF" : "#FFFFFF"

        readonly property string colorCoinListHighlightGradient: dark_theme ? "#2C2E40" : "#E0E6F0"

        readonly property string colorRectangleBorderGradient1: dark_theme ? "#2A2F48" : "#DDDDDD"
        readonly property string colorRectangleBorderGradient2: dark_theme ? "#0D1021" : "#EFEFEF"

        readonly property string colorChartText: dark_theme ? "#405366" : "#B5B9C1"
        readonly property string colorChartLegendLine: dark_theme ? "#3F5265" : "#BDC0C8"
        readonly property string colorChartGrid: dark_theme ? "#202333" : "#E6E8ED"
        readonly property string colorChartLineText: dark_theme ? "#405366" : "#FFFFFF"

        readonly property string colorChartMA1: dark_theme ? "#5BC6FA" : "#5BC6FA"
        readonly property string colorChartMA2: dark_theme ? "#F1D17F" : "#F1D17F"

        readonly property string colorLineBasic: dark_theme ? "#303344" : "#303344"


        readonly property string colorText: dark_theme ? Style.colorWhite1 : "#405366"
        readonly property string colorText2: dark_theme ? "#79808C" : "#3C5368"
        readonly property string colorTextDisabled: dark_theme ? Style.colorWhite8 : "#B5B9C1"
        readonly property
        var colorButtonDisabled: ({
            "default": Style.colorTheme9,
            "primary": Style.colorGreen3,
            "danger": Style.colorRed3
        })
        readonly property
        var colorButtonHovered: ({
            "default": Style.colorTheme6,
            "primary": Style.colorGreen,
            "danger": Style.colorRed
        })
        readonly property
        var colorButtonEnabled: ({
            "default": Style.colorRectangle,
            "primary": Style.colorGreen2,
            "danger": Style.colorRed2
        })
        readonly property
        var colorButtonTextDisabled: ({
            "default": Style.colorWhite8,
            "primary": Style.colorWhite13,
            "danger": Style.colorWhite13
        })
        readonly property
        var colorButtonTextHovered: ({
            "default": Style.colorText,
            "primary": Style.colorWhite11,
            "danger": Style.colorWhite11
        })
        readonly property
        var colorButtonTextEnabled: ({
            "default": Style.colorText,
            "primary": Style.colorWhite11,
            "danger": Style.colorWhite11
        })
        readonly property string colorPlaceholderText: Style.colorWhite9
        readonly property string colorSelectedText: Style.colorTheme9
        readonly property string colorSelection: Style.colorGreen2

        readonly property string colorTrendingLine: dark_theme ? Style.colorGreen : "#37a6ef"
        readonly property string colorTrendingUnderLine: dark_theme ? Style.colorGradient3 : "#e3f2fd"

        readonly property string modalValueColor: colorWhite4

        function getValueColor(v) {
            v = parseFloat(v)
            if (v !== 0)
                return v > 0 ? Style.colorGreen : Style.colorRed

            return Style.colorWhite4
        }

        function getCoinTypeColor(type) {
            return getCoinColor(type === "ERC-20" ? "ETH" :
                type === "QRC-20" ? "QTUM" :
                type === "Smart Chain" ? "KMD" :
                "BTC")
        }

        function getCoinColor(ticker) {
            const c = colorCoin[ticker]
            return c || Style.colorTheme2
        }

        readonly property
        var colorCoin: ({
            "ARPA": "#CCD9E2",
            "BCH": "#8DC351",
            "BTC": "#F7931A",
            "CLC": "#0970DC",
            "FTC": "#FFFFFF",
            "GLEEC": "#8C41FF",
            "GRS": "#377E96",
            "DOGE": "#C3A634",
            "ETH": "#627EEA",
            "KMD": "#2B6680",
            "MORTY": "#A4764D",
            "RICK": "#A5CBDD",
            "EMC2": "#00CCFF",
            "DASH": "#008CE7",
            "RVN": "#384182",
            "DGB": "#006AD2",
            "FIRO": "#BB2100",
            "LTC": "#BFBBBB",
            "ZEC": "#ECB244",
            "ZER": "#FFFFFF",
            "NAV": "#7D59B5",
            "DP": "#E41D25",
            "ECA": "#A915DC",
            "QTUM": "#2E9AD0",
            "CHIPS": "#598182",
            "AXE": "#C63877",
            "PANGEA": "#D88245",
            "JUMBLR": "#2B4649",
            "DEX": "#43B7B6",
            "COQUI": "#79A541",
            "CRYPTO": "#F58736",
            "LABS": "#C1F6E1",
            "MGW": "#854F2F",
            "MONA": "#DEC799",
            "NMC": "#186C9D",
            "RFOX": "#D83331",
            "BOTS": "#F69B57",
            "MCL": "#EA0000",
            "CCL": "#FFE400",
            "BET": "#F69B57",
            "SUPERNET": "#F69B57",
            "OOT": "#25AAE1",
            "REVS": "#F69B57",
            "ILN": "#523170",
            "VRSC": "#3164D3",
            "THC": "#819F6F",
            "1INCH": "#95A7C5",
            "BAT": "#FF5000",
            "BUSD": "#EDB70B",
            "DAI": "#B68900",
            "USDC": "#317BCB",
            "PAX": "#EDE70A",
            "SUSHI": "#E25DA8",
            "TUSD": "#2E3181",
            "AWC": "#31A5F6",
            "VRA": "#D70A41",
            "SPACE": "#E44C65",
            "QC": "#00D7B3",
            "PBC": "#64A3CB",
            "AAVE": "#9C64A6",
            "ANT": "#33DAE6",
            "AGI": "#6815FF",
            "BAND": "#526BFF",
            "BLK": "#191919",
            "BNT": "#000D2B",
            "BTCZ": "#F5B036",
            "CEL": "#4055A6",
            "CENNZ": "#2E87F1",
            "COMP": "#00DBA3",
            "CRO": "#243565",
            "CVC": "#3AB03E",
            "CVT": "#4B0082",
            "DODO": "#FFF706",
            "ELF": "#2B5EBB",
            "ENJ": "#6752C3",
            "EURS": "#2F77ED",
            "FUN": "#EF1C70",
            "GNO": "#00B0CC",
            "HOT": "#983EFF",
            "IOTX": "#00CDCE",
            "KNC": "#117980",
            "LEO": "#F79B2C",
            "LINK": "#356CE4",
            "LRC": "#32C2F8",
            "MANA": "#FF3C6C",
            "MATIC": "#1E61ED",
            "MED": "#00B5FF",
            "MKR": "#1BAF9F",
            "NPXS": "#F3CB00",
            "POWR": "#05BCAA",
            "QI": "#FFFFFF",
            "QIAIR": "#FEFEFE",
            "QKC": "#2175B4",
            "QNT": "#46DDC8",
            "REP": "#0E0E21",
            "REV": "#78034D",
            "RLC": "#FFE100",
            "SFUSD": "#9881B8",
            "SNT": "#596BED",
            "SNX": "#00D1FF",
            "SOULJA": "#8F734A",
            "STORJ": "#2683FF",
            "TSL": "#64B082",
            "VRM": "#586A7A",
            "WSB": "#FEBB84",
            "WBTC": "#CCCCCC",
            "YFI": "#006BE6",
            "ZRX": "#302C2C",
            "UNI": "#FF007A"
        })
    }

    QtObject {
        id: _font
        property real fontDensity: 1.0
        property real languageDensity: {
            switch (API.app.settings_pg.lang) {
                case "en":
                    return 0.99999
                    break
                case "fr":
                    return Qt.platform.os === "windows" ? 0.98999 : 0.90
                    break
                case "tr":
                    return 0.99999
                    break
                case "ru":
                    return 0.99999
                    break
                default:
                    return 0.99999
            }
        }
        property string fontFamily: "Ubuntu"
        property font head1: Qt.font({
            pixelSize: 96 * fontDensity,
            letterSpacing: -1.5,
            family: fontFamily,
            weight: Font.Light
        })
        property font head2: Qt.font({
            pixelSize: 60 * fontDensity,
            letterSpacing: -0.5,
            family: fontFamily,
            weight: Font.Light
        })
        property font head3: Qt.font({
            pixelSize: 48 * fontDensity,
            letterSpacing: 0,
            family: fontFamily,
            weight: Font.Normal
        })
        property font head4: Qt.font({
            pixelSize: 34 * fontDensity,
            letterSpacing: 0.25,
            family: fontFamily,
            weight: Font.Normal
        })
        property font head5: Qt.font({
            pixelSize: 24 * fontDensity,
            letterSpacing: 0,
            family: fontFamily,
            weight: Font.Normal
        })
        property font head6: Qt.font({
            pixelSize: 20 * fontDensity,
            letterSpacing: 0.15,
            family: fontFamily,
            weight: Font.Medium
        })
        property font subtitle1: Qt.font({
            pixelSize: 16 * fontDensity,
            letterSpacing: 0.15,
            family: fontFamily,
            weight: Font.Normal
        })
        property font subtitle2: Qt.font({
            pixelSize: 14 * fontDensity,
            letterSpacing: 0.1,
            family: fontFamily,
            weight: Font.Medium
        })
        property font body1: Qt.font({
            pixelSize: 16 * fontDensity,
            letterSpacing: 0.5,
            family: fontFamily,
            weight: Font.Normal
        })
        property font body2: Qt.font({
            pixelSize: 14 * fontDensity,
            letterSpacing: 0.25,
            family: fontFamily,
            weight: Font.Normal
        })
        property font button: Qt.font({
            pixelSize: 14 * fontDensity,
            letterSpacing: 1.25,
            capitalization: Font.AllUppercase,
            family: fontFamily,
            weight: Font.Medium
        })
        property font caption: Qt.font({
            pixelSize: 12 * fontDensity,
            letterSpacing: 0.4,
            family: fontFamily,
            weight: Font.Normal
        })
        property font overLine: Qt.font({
            pixelSize: 10 * fontDensity,
            letterSpacing: 1.25,
            capitalization: Font.AllUppercase,
            family: fontFamily,
            weight: Font.Normal
        })
    }
}
