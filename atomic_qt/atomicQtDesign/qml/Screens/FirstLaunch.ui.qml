import QtQuick 2.12
import QtQuick.Layouts 1.3
import Qt.SafeRenderer 1.1
import QtQuick.Studio.Effects 1.0
import QtQuick.Studio.Components 1.0
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    image_scale: 0.7
    image_path: General.image_path + "komodo-icon.png"
    title: "Welcome!"
    content: RowLayout {
        id: buttons_list
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.itemPadding

        Button {
            id: new_user_button
            text: qsTr("New User")
        }

        Button {
            id: seed_recovery
            text: qsTr("Recover Seed")
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

