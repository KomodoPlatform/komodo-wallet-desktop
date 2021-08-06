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

import App 1.0 as App

DexRectangle
{
    id: app

    property string currentWalletName: ""
    property int page: current_page === 5 ? deepPage : current_page
    property int deepPage: 0
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

    QtObject {
        id: _font
        property real fontDensity: App.DexTypo.fontDensity
        property string fontFamily:  App.DexTypo.fontFamily
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
        data["bigSidebarLogo"] = DexTheme.bigSidebarLogo
        data["smallSidebarLogo"] = DexTheme.smallSidebarLogo
        data["chartTheme"] = DexTheme.chartTheme
        let r = API.qt_utilities.save_theme(name + ".json", data, true)
        console.log(r)
    }

    function load_theme(name) {
        let data = API.qt_utilities.load_theme(name)
        if(!("theme" in data)) {
            console.log('UNDEFINED')
            App.DexTheme.theme = "undefined"
        }else {
            console.log("DEFINED")
        }
        for (let i in data) {
            if (typeof(data[i]) === "boolean") {
                eval("App.DexTheme." + i.toString() + " = " + data[i].toString())
            }
            else if (i.toString().indexOf("[int]") !== -1) {
                let real_i = i;
                i = i.replace("[int]", "")
                console.log("theme." + i.toString() + " = " + data[real_i] + "")
                eval("App.DexTheme." + i.toString() + " = " + data[real_i])
            } else {
                console.log("theme." + i.toString() + " = '" + data[i] + "'")
                eval("App.DexTheme." + i.toString() + " = '" + data[i] + "'")
            }
        }
        Qaterial.Style.accentColor = App.DexTheme.accentColor
        console.log("END APPLY %1".arg(name))
    }

    color: App.DexTheme.surfaceColor
    radius: 0
    border.width: 0
    border.color: 'transparent'
    
}
