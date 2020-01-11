import QtQuick 2.12
import atomicQtDesign 1.0

Rectangle {
    color: "#1E2938"
    width: Constants.width
    height: Constants.height

//    FirstLaunch {
//        id: welcome_page
//        anchors.fill: parent
//    }

    RecoverSeed {
        id: recover_seed_page
        anchors.fill: parent
    }
}
