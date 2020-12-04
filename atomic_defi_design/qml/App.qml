import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "Screens"
import "Constants"
import "Components"

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

        current_page = force ? idx_first_launch : firstPage()
    }

    Component.onCompleted: openFirstLaunch()

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

                // Fill all coins list
                General.all_coins = API.app.get_all_coins()

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
    LogModal {
        id: error_log_modal
    }

    function showError(title, content) {
        if(content === undefined || content === null) return
        error_log_modal.header = title
        error_log_modal.field.text = content
        error_log_modal.open()
    }

    // Toast
    ToastManager {
        id: toast
    }

    // Update Modal
    UpdateModal {
        id: update_modal
    }

    UpdateNotificationLine {
        anchors.top: parent.top
        anchors.right: parent.right
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
