import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"


ColumnLayout {
    function inCurrentPage() {
        return  wallet.inCurrentPage() && main_layout.currentIndex === 1
    }

    ColumnLayout {
        Layout.margins: layout_margin
        Layout.fillWidth: true

        spacing: 20

        DefaultText {
            text_value: API.get().empty_string + ("< " + qsTr("Back"))
            font.bold: true

            MouseArea {
                anchors.fill: parent
                onClicked: main_layout.currentIndex = 0
            }
        }

        RowLayout {
            Layout.fillWidth: true

            DefaultText {
                text_value: API.get().empty_string + (qsTr("Address Book"))
                font.bold: true
                font.pixelSize: Style.textSize3
                Layout.fillWidth: true
            }

            DefaultButton {
                Layout.alignment: Qt.AlignRight
                text: API.get().empty_string + (qsTr("New Contact"))
                onClicked: {
                    address_list.push({ name: "Kekkeri " + address_list.length })
                    address_list = address_list
                }
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
        }

        DefaultListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: API.get().address_book

            delegate: Item {
                readonly property int line_height: 150
                readonly property int bottom_margin: layout_margin
                readonly property bool is_last_item: index === model.length - 1

                width: list.width
                height: line_height + (is_last_item ? 0 : bottom_margin)

                FloatingBackground {
                    anchors.fill: parent
                    anchors.bottomMargin: is_last_item ? 0 : bottom_margin

                    content: ColumnLayout {
                        DefaultText {
                            Layout.topMargin: layout_margin
                            Layout.leftMargin: layout_margin
                            text_value: modelData.name
                        }

                        HorizontalLine {
                            Layout.fillWidth: true
                        }

                        DefaultListView {
                            id: address_list
                            Layout.fillWidth: true
                            model: modelData.addresses

                            delegate: Item {

                                    width: list.width

                                    height: 25

                                    DefaultText {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: layout_margin

                                        font.pixelSize: Style.textSizeSmall3
                                        text_value: modelData.type
                                    }

                                    DefaultText {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: layout_margin * 5

                                        font.pixelSize: Style.textSizeSmall3
                                        text_value: modelData.address
                                    }
                                }

                        }
                    }
                }
            }
        }
    }
}








/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
