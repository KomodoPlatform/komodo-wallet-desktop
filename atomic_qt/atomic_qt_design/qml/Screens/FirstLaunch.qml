import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    function onClickedNewUser() {}
    function onClickedRecoverSeed() {}

    image_scale: 0.7
    image_path: General.image_path + "komodo-icon.png"
    title: "Welcome!"
    content: RowLayout {
        spacing: Style.itemPadding

        Button {
            text: qsTr("New User")
            onClicked: onClickedNewUser()
        }

        Button {
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

