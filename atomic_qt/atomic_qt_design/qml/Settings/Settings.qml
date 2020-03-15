import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

Item {
    function disconnect() {
        API.get().disconnect()
        onDisconnect()
    }

    function reset() {

    }

    property var fiats: (["USD", "EUR"])

    ColumnLayout {
        anchors.centerIn: parent
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: Style.textSize2
            text: API.get().empty_string + (qsTr("Settings"))
        }

        Rectangle {
            color: Style.colorTheme7
            radius: Style.rectangleCornerRadius

            Layout.alignment: Qt.AlignHCenter

            width: layout.childrenRect.width + layout.anchors.leftMargin * 2
            height: layout.childrenRect.height + layout.anchors.topMargin * 2

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.top: parent.top
                anchors.topMargin: anchors.leftMargin
                id: layout

                ComboBoxWithTitle {
                    id: combo_fiat
                    title: qsTr("Fiat")
                    Layout.fillWidth: true

                    field.model: fiats
                    field.onCurrentIndexChanged: {
                        API.get().fiat = fiats[field.currentIndex]
                    }
                    Component.onCompleted: {
                        field.currentIndex = fiats.indexOf(API.get().fiat)
                    }
                }

                RowLayout {
                    DefaultText {
                        Layout.alignment: Qt.AlignVCenter
                        text: API.get().empty_string + (qsTr("Language"))
                    }
                    Image {
                        Layout.alignment: Qt.AlignBottom
                        source: General.image_path + "lang/" + API.get().lang + ".png"
                        fillMode: Image.PreserveAspectFit
                        scale: 0.5
                    }
                }

                Grid {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                    Layout.bottomMargin: 15
                    clip: true

                    columns: 8
                    spacing: 10

                    layoutDirection: Qt.LeftToRight

                    Repeater {
                        model: API.get().get_available_langs()
                        delegate: Image {
                            source: General.image_path + "lang/" + model.modelData + ".png"
                            fillMode: Image.PreserveAspectFit
                            width: Style.textSize2

                            // Click area
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: {
                                    API.get().lang = model.modelData
                                }
                            }
                        }
                    }
                }

                HorizontalLine {
                    Layout.fillWidth: true
                }

                DangerButton {
                    text: API.get().empty_string + (qsTr("Delete Wallet"))
                    Layout.fillWidth: true
                    onClicked: {
                        API.get().delete_wallet(API.get().wallet_default_name)
                        disconnect()
                    }
                }

                DefaultButton {
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("Log out"))
                    onClicked: disconnect()
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
