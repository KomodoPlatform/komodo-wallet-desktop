import QtQuick 2.12
import QtQuick.Layouts 1.3
import "Screens"
import "Constants"

Rectangle {
    id: root
    color: "#1E2938"

    readonly property int idx_first_launch: 0
    readonly property int idx_recover_seed: 1
    readonly property int idx_new_user: 2
    readonly property int idx_login: 3
    property int current_page: idx_first_launch
    StackLayout {
        id: stack_layout
        anchors.fill: parent

        currentIndex: current_page

        FirstLaunch {
            function onClickedNewUser() { current_page = idx_new_user }
            function onClickedRecoverSeed() { current_page = idx_recover_seed }
        }

        RecoverSeed {}

        NewUser {}

        Login {
            function onClickedRecoverSeed() { current_page = idx_recover_seed }
            function onClickedLogin() {
                // TODO: Login here
                console.log("Logging in...")
            }
        }
    }
}
