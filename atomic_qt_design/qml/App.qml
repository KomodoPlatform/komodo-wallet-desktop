import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "Screens"
import "Constants"
import "Components"

Rectangle {
    id: app

    color: Style.colorTheme8

    function firstPage() {
        return !API.get().first_run() && API.get().is_there_a_default_wallet() ? idx_login : idx_first_launch
    }

    function cleanApp() {
        dashboard.reset()
    }

    function onDisconnect() { openFirstLaunch() }

    function openFirstLaunch(force) {        
        cleanApp()

        if(API.design_editor) {
            current_page = idx_dashboard
            return
        }

        current_page = force ? idx_first_launch : firstPage()
        first_launch.updateWallets()
    }

    Component.onCompleted: openFirstLaunch()

    readonly property int idx_first_launch: 0
    readonly property int idx_recover_seed: 1
    readonly property int idx_new_user: 2
    readonly property int idx_login: 3
    readonly property int idx_initial_loading: 4
    readonly property int idx_dashboard: 5
    property int current_page

    onCurrent_pageChanged: {
        if(current_page === idx_new_user) {
            new_user.onOpened()
        }
    }

    NoConnection {
        id: no_connection_page
        anchors.fill: parent
    }

    StackLayout {
        visible: !no_connection_page.visible

        anchors.fill: parent

        currentIndex: current_page

        FirstLaunch {
            id: first_launch
            onClickedNewUser: () => { current_page = idx_new_user }
            onClickedRecoverSeed: () => { current_page = idx_recover_seed }
            onClickedWallet: () => { current_page = idx_login }
        }

        RecoverSeed {
            onClickedBack: () => { openFirstLaunch() }
            postConfirmSuccess: () => { openFirstLaunch() }
        }

        NewUser {
            id: new_user
            onClickedBack: () => { openFirstLaunch() }
            postCreateSuccess: () => { openFirstLaunch() }
        }

        Login {
            onClickedBack: () => { openFirstLaunch(true) }
            postLoginSuccess: () => {
                initial_loading.check_loading_complete.running = true
                current_page = idx_initial_loading
                cleanApp()
            }
        }

        InitialLoading {
            id: initial_loading
            onLoaded: () => { current_page = idx_dashboard }
        }

        Dashboard {
            id: dashboard
        }
    }

    DefaultText {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.rightMargin: anchors.bottomMargin
        text: API.get().empty_string + (qsTr("gui version") + ":    " + API.get().get_version())
        font.pixelSize: Style.textSizeSmall
    }


    // Error Modal
    LogModal {
        id: error_log_modal
    }

    function showError(title, content) {
        if(content === undefined || content === null) return
        error_log_modal.title = title
        error_log_modal.field.text = content
        error_log_modal.open()
    }

    // Toast
    ToastManager {
        id: toast
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
