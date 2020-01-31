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
        return API.get().first_run() ? idx_first_launch : idx_login
    }

    readonly property int idx_first_launch: 0
    readonly property int idx_recover_seed: 1
    readonly property int idx_new_user: 2
    readonly property int idx_login: 3
    readonly property int idx_initial_loading: 4
    readonly property int idx_dashboard: 5
    property int current_page: API.design_editor ? idx_dashboard : firstPage()

    StackLayout {
        anchors.fill: parent

        currentIndex: current_page

        FirstLaunch {
            function onClickedNewUser() { current_page = idx_new_user }
            function onClickedRecoverSeed() { current_page = idx_recover_seed }
        }

        RecoverSeed {
            function onClickedBack() { current_page = firstPage() }
            function postConfirmSuccess() { current_page = firstPage() }
        }

        NewUser {
            function onClickedBack() { current_page = idx_first_launch }
            function postCreateSuccess() { current_page = firstPage() }
        }

        Login {
            function onClickedRecoverSeed() { current_page = idx_recover_seed }
            function postLoginSuccess() {
                initial_loading.check_loading_complete.running = true
                current_page = idx_initial_loading
            }
        }

        InitialLoading {
            id: initial_loading
            function onLoaded() { current_page = idx_dashboard }
        }

        Dashboard {

        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
