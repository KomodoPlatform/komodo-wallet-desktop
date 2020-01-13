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
    image_path: General.image_path + "setup-logs.svg"
    title: "Login"
    content: ColumnLayout {
        id: rows

        PasswordField {
            id: password_input
        }

        RowLayout {
            id: columns

            Button {
                id: recover_seed_button
                text: qsTr("Recover Seed")
            }

            Button {
                id: confirm_button
                text: qsTr("Login")
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

