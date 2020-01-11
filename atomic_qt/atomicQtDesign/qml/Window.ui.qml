import QtQuick 2.12
import "Screens"
import "Constants"

Rectangle {
    color: "#1E2938"
    width: General.width
    height: General.height

    //    FirstLaunch {
    //        id: welcome_screen
    //        anchors.fill: parent
    //    }

    //    RecoverSeed {
    //        id: recover_seed_screen
    //        anchors.fill: parent
    //    }

    //    NewUser {
    //        id: new_user_screen
    //        anchors.fill: parent
    //    }
    Login {
        id: login_screen
        anchors.fill: parent
    }
}
