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

    // Local
    function updateWallets() {
        wallets = API.get().get_wallets()
    }

    property var wallets: ([])

    image_scale: 0.7
    image_path: General.image_path + "komodo-icon.png"
    title: qsTr("Welcome!")
    content: ColumnLayout {
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.itemPadding

            PrimaryButton {
                text: qsTr("New User")
                Layout.fillWidth: true
                onClicked: onClickedNewUser()
            }

            DefaultButton {
                Layout.fillWidth: true
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

            model: wallets

            delegate: Rectangle {
                property bool hovered: false

                color: hovered ? Style.colorTheme7 : "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                width: 300
                height: 30

                // Click area
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: hovered = containsMouse
                    onClicked: {
                        API.get().wallet_default_name = model.modelData
                        onClickedWallet()
                    }
                }

                // Name
                DefaultText {
                    anchors.left: parent.left
                    anchors.leftMargin: 5

                    text: Style.listItemPrefix + model.modelData
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Line
                HorizontalLine {
                    visible: index !== wallets.length - 1
                    width: parent.width
                    color: Style.colorWhite9
                    anchors.bottom: parent.bottom
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

