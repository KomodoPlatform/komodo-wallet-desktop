import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Qt.labs.platform 1.0

import "../Constants"
import "../Components"

FloatingBackground {
    id: root

    property var notifications_list: ([])

    function reset() {
        visible = false
    }

    function showApp() {
        window.show()
        window.raise()
        window.requestActivate()
    }

    visible: false

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        hoverEnabled: true
    }

    // Events
    function onSwapStatusUpdated(old_swap_status, new_swap_status, swap_uuid) {
        // TODO: Add qsTr texts for statuses
        const obj = {
            title: qsTr("Swap status updated"),
            message: old_swap_status + " " + General.right_arrow_icon + " " + new_swap_status
        }

        notifications_list = [obj].concat(notifications_list)
        displayMessage(obj.title, obj.message)
    }


    // System
    Component.onCompleted: {
        API.get().notification_mgr.updateSwapStatus.connect(onSwapStatusUpdated)
    }

    function displayMessage(title, message) {
        tray.showMessage(title, message)
    }

    SystemTrayIcon {
        id: tray
        visible: true
        iconSource: General.coinIcon("KMD")
        onMessageClicked: {
            root.visible = true
            showApp()
        }

        tooltip: qsTr("AtomicDEX Pro")

        onActivated: showApp()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40

        spacing: 10

        DefaultText {
            text_value: API.get().empty_string + (qsTr("Notifications"))
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            font.pixelSize: Style.textSize2
        }

        HorizontalLine {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
        }

        InnerBackground {
            Layout.fillWidth: true
            Layout.fillHeight: true

            DefaultText {
                anchors.centerIn: parent
                visible: !list.visible
                text_value: API.get().empty_string + (qsTr("There isn't any notification"))
                font.pixelSize: Style.textSizeSmall2
            }

            DefaultListView {
                id: list

                visible: notifications_list.length !== 0

                anchors.fill: parent
                model: notifications_list

                delegate: Item {
                    width: list.width
                    height: 60

                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        DefaultText {
                            text_value: API.get().empty_string + (modelData.title)
                            font.pixelSize: Style.textSizeSmall4
                        }

                        DefaultText {
                            text_value: API.get().empty_string + (modelData.message)
                            font.pixelSize: Style.textSizeSmall1
                        }
                    }

                    HorizontalLine {
                        visible: index !== notifications_list.length - 1
                        width: parent.width - 4

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -height/2
                        light: true
                    }
                }
            }
        }


        RowLayout {
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: parent.spacing
            spacing: 10

            DefaultButton {
                text: API.get().empty_string + (qsTr("Pop Notification"))
                onClicked: {
                    onSwapStatusUpdated("ongoing", "finished", "123456")
                }
            }

            DefaultButton {
                text: API.get().empty_string + (qsTr("Close"))
                onClicked: root.visible = false
            }
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
