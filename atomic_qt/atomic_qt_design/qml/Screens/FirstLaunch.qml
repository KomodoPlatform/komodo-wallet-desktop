import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
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

            DefaultButton {
                Layout.fillWidth: true
                text: API.get().empty_string + (qsTr("Recover Seed"))
                onClicked: onClickedRecoverSeed()
            }

            PrimaryButton {
                Layout.fillWidth: true
                text: API.get().empty_string + (qsTr("New User"))
                onClicked: onClickedNewUser()
            }
        }

        // Wallets
        ColumnLayout {
            visible: wallets.length > 0
            // Name
            DefaultText {
                Layout.topMargin: 30
                text: API.get().empty_string + (qsTr("Wallets"))
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

                        text: API.get().empty_string + (Style.listItemPrefix + model.modelData)
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
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

