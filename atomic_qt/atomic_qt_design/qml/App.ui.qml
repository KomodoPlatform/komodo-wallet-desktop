import QtQuick 2.12
import "Screens"
import "Constants"

Rectangle {
    id: root
    color: "#1E2938"

    property string current_page: "login"

    FirstLaunch {
        id: welcome_screen
        anchors.fill: parent
        visible: current_page == "first_launch"
    }

    RecoverSeed {
        id: recover_seed_screen
        anchors.fill: parent
        visible: current_page == "recover_seed"
    }

    NewUser {
        id: new_user_screen
        anchors.fill: parent
        visible: current_page == "new_user"
    }

    Login {
        id: login_screen
        anchors.fill: parent
        visible: current_page == "login"
    }

    states: [
        State {
            name: "FirstLaunch"
            when: atomic_app.first_run() === true
            PropertyChanges {
                target: root
                current_page: "first_launch"
            }
        },
        State {
            name: "Login"
            when: atomic_app.first_run() === false
            PropertyChanges {
                target: current_page
                current_page: "login"
            }
        }
    ]
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

