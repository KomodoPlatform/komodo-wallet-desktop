import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "Screens"
import "Constants"
import "Components"
import "Dashboard"

Rectangle {
    id: app

    color: Style.colorTheme8

    property string selected_wallet_name: ""

    function firstPage() {
        return !API.app.first_run() && selected_wallet_name !== "" ? idx_login : idx_first_launch
    }

    function onDisconnect() { openFirstLaunch() }

    function openFirstLaunch(force=false, set_wallet_name=true) {
        if(set_wallet_name) selected_wallet_name = API.app.wallet_mgr.wallet_default_name

        General.initialized_orderbook_pair = false

        current_page = force ? idx_first_launch : firstPage()
    }

    // Preload Chart
    signal pairChanged(string base, string rel)
    property var chart_component
    property var chart_object

    Component.onCompleted: {
        openFirstLaunch()

        // Load the chart
        if(!chart_component) chart_component = Qt.createComponent("./Exchange/Trade/CandleStickChart.qml")
        if(!chart_object) {
            chart_object = chart_component.createObject(app)
            chart_object.visible = false
        }
    }

    readonly property int idx_first_launch: 0
    readonly property int idx_recover_seed: 1
    readonly property int idx_new_user: 2
    readonly property int idx_login: 3
    readonly property int idx_initial_loading: 4
    readonly property int idx_dashboard: 5
    property int current_page

    Component {
        id: no_connection

        NoConnection {}
    }

    Component {
        id: first_launch

        FirstLaunch {
            onClickedNewUser: () => { current_page = idx_new_user }
            onClickedRecoverSeed: () => { current_page = idx_recover_seed }
            onClickedWallet: () => { current_page = idx_login }
        }
    }

    Component {
        id: recover_seed

        RecoverSeed {
            onClickedBack: () => { openFirstLaunch() }
            postConfirmSuccess: () => { openFirstLaunch(false, false) }
        }
    }

    Component {
        id: new_user

        NewUser {
            onClickedBack: () => { openFirstLaunch() }
            postCreateSuccess: () => { openFirstLaunch(false, false) }
            Component.onCompleted: console.log("Initialized new user")
        }
    }

    Component {
        id: login

        Login {
            onClickedBack: () => { openFirstLaunch(true) }
            postLoginSuccess: () => {
                current_page = idx_initial_loading
            }
            Component.onCompleted: console.log("Initialized login")
        }
    }

    Component {
        id: initial_loading

        InitialLoading {
            onLoaded: () => { current_page = idx_dashboard }
        }
    }


    Component {
        id: dashboard

        Dashboard {}
    }

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: {
            if(!API.app.internet_checker.internet_reacheable)
                return no_connection

            switch(current_page) {
            case idx_dashboard: return dashboard
            case idx_first_launch: return first_launch
            case idx_initial_loading: return initial_loading
            case idx_login: return login
            case idx_new_user: return new_user
            case idx_recover_seed: return recover_seed
            default: return undefined
            }
        }
    }

    // Error Modal
    ModalLoader {
        id: error_log_modal
        sourceComponent: LogModal {}
    }

    function showError(title, content) {
        if(content === undefined || content === null) return
        error_log_modal.open()
        error_log_modal.item.header = title
        error_log_modal.item.field.text = content
    }

    // Toast
    ToastManager {
        id: toast
    }

    // Update Modal
    readonly property bool status_good: API.app.update_checker.update_status.rpc_code === 200
    readonly property bool update_needed: status_good && API.app.update_checker.update_status.update_needed
    ModalLoader {
        id: update_modal
        sourceComponent: UpdateModal {}
    }

    UpdateNotificationLine {
        anchors.top: parent.top
        anchors.right: parent.right
    }

    // Fatal Error Modal
    FatalErrorModal {
        id: fatal_error_modal
        visible: false
    }
}
