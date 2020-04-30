import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root

    property bool wrong_password: false
    property string seed: ''

    function tryViewSeed() {
        if(!submit_button.enabled) return

        const result = API.get().retrieve_seed(API.get().wallet_default_name, input_password.field.text)

        if(result !== 'wrong password') {
            seed = result
            wrong_password = false
        }
        else {
            wrong_password = true
        }
    }

    width: 500

    onClosed: {
        seed = ''
        wrong_password = false
        input_password.reset()
    }

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: API.get().empty_string + (qsTr("View Seed"))
        }

        ColumnLayout {
            visible: seed === ''

            DefaultText {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.alignment: Qt.AlignHCenter

                text: API.get().empty_string + (qsTr("Please enter your password to view the seed."))
            }

            PasswordForm {
                id: input_password
                Layout.fillWidth: true
                confirm: false
                field.onAccepted: tryViewSeed()
            }

            DefaultText {
                text: API.get().empty_string + (qsTr("Wrong Password"))
                color: Style.colorRed
                visible: wrong_password
            }
        }

        TextAreaWithTitle {
            visible: seed !== ''

            title: API.get().empty_string + (qsTr("Seed"))
            field.text: seed
            field.readOnly: true
            copyable: true
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (seed === '' ? qsTr("Cancel") : qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            PrimaryButton {
                id: submit_button
                visible: seed === ''
                text: API.get().empty_string + (qsTr("View"))
                Layout.fillWidth: true
                enabled: input_password.isValid()
                onClicked: tryViewSeed()
            }
        }
    }
}
