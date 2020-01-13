import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    image_scale: 0.7
    image_path: General.image_path + "setup-welcome-wallet.svg"
    title: "New User"
    content: ColumnLayout {
        id: rows
        width: 400

        TextFieldWithTitle {
            id: generated_seed
            title: qsTr("Generated Seed")
            // TODO: Delete this text
            field.readOnly: true
            field.text: "this is a test seed gossip rubber flee just connect manual any salmon limb suffer now turkey essence naive daughter system begin quantum page"
        }

        TextFieldWithTitle {
            id: confirm_seed_input
            title: qsTr("Confirm Seed")
            field.placeholderText: qsTr("Enter the generated seed here")
        }

        PasswordField {
            id: password_input
        }

        RowLayout {
            id: columns

            Button {
                id: back_button
                text: qsTr("Back")
            }

            Button {
                id: confirm_button
                text: qsTr("Create")
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

