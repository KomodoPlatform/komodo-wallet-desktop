import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    function onClickedRecoverSeed() {}
    function onClickedLogin() {}

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
                onClicked: onClickedRecoverSeed()
            }

            Button {
                id: confirm_button
                text: qsTr("Login")
                onClicked: onClickedLogin()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

