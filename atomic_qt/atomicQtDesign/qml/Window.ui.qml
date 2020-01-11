import QtQuick 2.12
import "Screens"
import "Constants"

Rectangle {
    color: "#1E2938"
    width: Style.width
    height: Style.height

    //    FirstLaunch {
    //        id: welcome_page
    //        anchors.fill: parent
    //    }
    RecoverSeed {
        id: recover_seed_page
        anchors.fill: parent
    }
}
