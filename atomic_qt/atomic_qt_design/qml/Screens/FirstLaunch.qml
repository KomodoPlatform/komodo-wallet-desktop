import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

SetupPage {
    // Override
    function onClickedNewUser() {}
    function onClickedRecoverSeed() {}
    function onClickedWallet() {}

    image_scale: 0.7
    image_path: General.image_path + "komodo-icon.png"
    title: qsTr("Welcome!")
    content: ColumnLayout {
        RowLayout {
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


        // Name
        DefaultText {
            Layout.topMargin: 30
            text: "Wallets"
        }

        HorizontalLine {
            Layout.fillWidth: true
        }

        ListView {
            ScrollBar.vertical: ScrollBar {}
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: contentItem.childrenRect.height
            clip: true

            model: API.get().get_wallets()

            delegate: Rectangle {
                property bool hovered: false

                color: hovered ? Style.colorTheme4 : "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                width: 200
                height: 50

                // Click area
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: hovered = containsMouse
                    onClicked: {
                        API.get().set_default_wallet(model.modelData)
                        onClickedWallet()
                    }
                }

                // Name
                DefaultText {
                    anchors.left: parent.left
                    anchors.leftMargin: 5

                    text: model.modelData
                    anchors.verticalCenter: parent.verticalCenter
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

