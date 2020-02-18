import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "Screens"
import "Constants"
import "Components"

Rectangle {
    color: Style.colorTheme8

    function firstPage() {
        return !API.get().first_run() && API.get().is_there_a_default_wallet() ? idx_login : idx_first_launch
    }

    function onDisconnect() { openFirstLaunch() }

    function openFirstLaunch(force) {
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
    property int current_page: API.design_editor ? idx_dashboard : 1337

    StackLayout {
        anchors.fill: parent

        currentIndex: current_page

        FirstLaunch {
            id: first_launch
            function onClickedNewUser() { current_page = idx_new_user }
            function onClickedRecoverSeed() { current_page = idx_recover_seed }
            function onClickedWallet() { current_page = idx_login }
        }

        RecoverSeed {
            function onClickedBack() { openFirstLaunch() }
            function postConfirmSuccess() { openFirstLaunch() }
        }

        NewUser {
            function onClickedBack() { openFirstLaunch() }
            function postCreateSuccess() { openFirstLaunch() }
        }

        Login {
            function onClickedBack() { openFirstLaunch(true) }
            function postLoginSuccess() {
                initial_loading.check_loading_complete.running = true
                current_page = idx_initial_loading
                dashboard.reset()
            }
        }

        InitialLoading {
            id: initial_loading
            function onLoaded() { current_page = idx_dashboard }
        }

        Dashboard {
            id: dashboard
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
