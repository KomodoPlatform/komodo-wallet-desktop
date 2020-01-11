import QtQuick 2.12
import QtQuick.Layouts 1.3
import Qt.SafeRenderer 1.1
import QtQuick.Studio.Effects 1.0
import QtQuick.Studio.Components 1.0
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

Item {
    Image {
        id: image1
        antialiasing: true
        scale: 0.5
        source: General.image_path + "komodo-icon.png"
    }

    ColumnLayout {
        id: window_layout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        transformOrigin: Item.Center
        spacing: 20

        Image {
            id: image
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: General.image_path + "setup-welcome-wallet.svg"
            scale: 1
        }

        PaneWithTitle {
            title: "New User"

            inside: ColumnLayout {
                id: rows

                TextFieldWithTitle {
                    id: generated_seed
                    title: qsTr("Generated Seed")
                    // TODO: Delete this text
                    field.text: "this is a test seed gossip rubber flee just connect manual any salmon limb suffer now turkey essence naive daughter system begin quantum page"
                }

                TextFieldWithTitle {
                    id: confirm_seed_input
                    title: qsTr("Confirm Seed")
                    field.placeholderText: qsTr("Enter the generated seed here")
                }

                TextFieldWithTitle {
                    id: password_input
                    title: qsTr("Password")
                    field.placeholderText: qsTr("Enter a password for your wallet")
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
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

