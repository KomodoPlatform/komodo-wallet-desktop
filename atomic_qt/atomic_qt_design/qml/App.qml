import QtQuick 2.12
import QtQuick.Layouts 1.3
import "Screens"
import "Constants"

Rectangle {
    id: root
    color: "#1E2938"

    function firstPage() {
        return MockAPI.getAtomicApp().first_run() ? idx_first_launch : idx_login
    }

    readonly property int idx_first_launch: 0
    readonly property int idx_recover_seed: 1
    readonly property int idx_new_user: 2
    readonly property int idx_login: 3
    property int current_page: firstPage()

    StackLayout {
        id: stack_layout
        anchors.fill: parent

        currentIndex: current_page

        FirstLaunch {
            function onClickedNewUser() { current_page = idx_new_user }
            function onClickedRecoverSeed() { current_page = idx_recover_seed }
        }

        RecoverSeed {
            function onClickedBack() { current_page = firstPage() }
        }

        NewUser {
            function onClickedBack() { current_page = idx_first_launch }
            function onClickedCreate() {
                // TODO: Create wallet here
                console.log("Creating wallet...")
            }
        }

        Login {
            function onClickedRecoverSeed() { current_page = idx_recover_seed }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
