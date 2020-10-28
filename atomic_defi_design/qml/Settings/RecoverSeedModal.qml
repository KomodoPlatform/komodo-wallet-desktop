import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"

BasicModal {
    id: root

    property bool wrong_password: false

    function tryViewSeed() {
        if(!submit_button.enabled) return

        const result = API.app.retrieve_seed(API.app.wallet_default_name, input_password.field.text)

        if(result !== 'wrong password') {
            seed_text.field.text = result
            wrong_password = false
            root.nextPage()
        }
        else {
            wrong_password = true
        }
    }

    width: 500

    onClosed: {
        wrong_password = false
        input_password.reset()
        seed_text.reset()
        currentIndex = 0
    }

    ModalContent {
        title: qsTr("View Seed")

        ColumnLayout {
            DefaultText {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.alignment: Qt.AlignHCenter

                text_value: qsTr("Please enter your password to view the seed.")
            }

            PasswordForm {
                id: input_password
                Layout.fillWidth: true
                confirm: false
                field.onAccepted: tryViewSeed()
            }

            DefaultText {
                text_value: qsTr("Wrong Password")
                color: Style.colorRed
                visible: wrong_password
            }
        }

        // Buttons
        footer: [
            DefaultButton {
                text: qsTr("Cancel")
                Layout.fillWidth: true
                onClicked: root.close()
            },

            PrimaryButton {
                id: submit_button
                text: qsTr("View")
                Layout.fillWidth: true
                enabled: input_password.isValid()
                onClicked: tryViewSeed()
            }
        ]
    }

    ModalContent {
        title: qsTr("View Seed")

        TextAreaWithTitle {
            id: seed_text
            title: qsTr("Seed")
            field.readOnly: true
            copyable: true
        }

        // Buttons
        footer: [
            DefaultButton {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }
        ]
    }
}
