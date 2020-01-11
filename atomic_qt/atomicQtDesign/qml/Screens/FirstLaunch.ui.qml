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
        spacing: 100

        Image {
            id: komodo_logo
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: General.image_path + "komodo-logo.png"
        }

        Column {
            id: column
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing: Style.paneTitleOffset

            PaneWithTitle {
                title: "Welcome!"
                inside: RowLayout {
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
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

