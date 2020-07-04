import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"
import ".."

// Open Enable Coin Modal
DefaultModal {
    id: root

    width: 800

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: API.get().empty_string + (qsTr("Confirm Exchange Details"))
        }

        OrderContent {
            Layout.topMargin: 25
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: Layout.leftMargin
            height: 120
            Layout.alignment: Qt.AlignHCenter

            item: ({
                    my_info: {
                       my_coin: getTicker(true),
                       other_coin: getTicker(false),
                       my_amount: form_base.field.text,
                       other_amount: form_rel.field.text
                    },

                    uuid: '',
                    date: '',
                   })
            in_modal: true
        }

        PriceLine {
            Layout.alignment: Qt.AlignHCenter
        }

        HorizontalLine {
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.fillWidth: true
        }

        FloatingBackground {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10

            color: Style.colorTheme5

            width: warning_texts.width + 20
            height: warning_texts.height + 20

            ColumnLayout {
                id: warning_texts
                anchors.centerIn: parent

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter

                    text_value: API.get().empty_string + (qsTr("This swap request can not be undone and is a final event!"))
                }

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter

                    text_value: API.get().empty_string + (qsTr("This transaction can take up to 10 mins - DO NOT close this application!"))
                    font.pixelSize: Style.textSizeSmall4
                }
            }
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (qsTr("Cancel"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            PrimaryButton {
                text: API.get().empty_string + (qsTr("Confirm"))
                Layout.fillWidth: true
                onClicked: {
                    root.close()

                    trade(getTicker(true), getTicker(false))
                }
            }
        }
    }
}
