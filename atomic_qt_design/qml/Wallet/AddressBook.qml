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
                readonly property bool is_last_item: index === address_list.length - 1

                width: list.width
                height: line_height + (is_last_item ? 0 : bottom_margin)

                InnerBackground {
                    anchors.fill: parent
                    anchors.bottomMargin: is_last_item ? 0 : bottom_margin
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
