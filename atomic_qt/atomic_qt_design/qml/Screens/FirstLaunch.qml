import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    id: page

    function onClickedNewUser() {}
    function onClickedRecoverSeed() {}

    image_scale: 0.7
    image_path: General.image_path + "komodo-icon.png"
    title: "Welcome!"
    content: RowLayout {
        id: buttons_list
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.itemPadding

        Button {
            id: button_new_user
            text: qsTr("New User")
            onClicked: onClickedNewUser()
        }

        Button {
            id: button_seed_recovery
            text: qsTr("Recover Seed")
            onClicked: onClickedRecoverSeed()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

