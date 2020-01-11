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
    ColumnLayout {
        id: window_layout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        transformOrigin: Item.Center
        spacing: 20

        Rectangle {
            id: rectangle
            color: "#283547"
            radius: 100
            implicitWidth: image.implicitWidth
            implicitHeight: image.implicitHeight
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Image {
                id: image
                source: General.image_path + "setup-logs.svg"
                scale: 0.7
                antialiasing: true
            }
        }

        PaneWithTitle {
            title: "Login"
            inside: ColumnLayout {
                id: rows

                TextFieldWithTitle {
                    id: password_input
                    title: qsTr("Password")
                    field.placeholderText: qsTr("Enter your password")
                }

                RowLayout {
                    id: columns

                    Button {
                        id: recover_seed_button
                        text: qsTr("Recover Seed")
                    }

                    Button {
                        id: confirm_button
                        text: qsTr("LOGIN")
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

