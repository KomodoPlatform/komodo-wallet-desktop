import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"
import ".."

DefaultModal {
    id: root

    width: 900

    onClosed: {
        accept_eula.checked = false
        accept_tac.checked = false
    }

    property var onConfirm: () => {}
    property bool close_only: false

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: API.get().empty_string + (qsTr("Disclaimer and ToS"))
        }


        Rectangle {
            id: eula_rect
            color: Style.colorTheme7
            radius: Style.rectangleCornerRadius
            height: 400
            Layout.fillWidth: true
            Flickable {
                ScrollBar.vertical: ScrollBar { }

                anchors.fill: parent
                anchors.margins: 20

                clip: true
                contentWidth: eula_text.width
                contentHeight: eula_text.height

                DefaultText {
                    id: eula_text
                    text: API.get().empty_string + (getEula())

                    width: eula_rect.width - 40
                }
            }
        }

        // Checkboxes
        CheckBox {
            id: accept_eula
            visible: !close_only
            text: API.get().empty_string + (qsTr("Accept EULA"))
        }

        CheckBox {
            id: accept_tac
            visible: !close_only
            text: API.get().empty_string + (qsTr("Accept Terms and Conditions"))
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (close_only ? qsTr("Close") : qsTr("Cancel"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            PrimaryButton {
                visible: !close_only
                text: API.get().empty_string + (qsTr("Confirm"))
                Layout.fillWidth: true
                enabled: accept_eula.checked && accept_tac.checked
                onClicked: {
                    onConfirm()
                    root.close()
                }
            }
        }
    }

    function getEula() {
        return qsTr(
"<h2>This will be the title</h2>
This will be eula textd
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula textasda
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textasdasd
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula textadas
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula textasda
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textThis will be eula textasda
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textasdasd
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula textadas
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula textasda
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textThis will be eula textasda
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textasdasd
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula textadas
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula textasda
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textThis will be eula textasda
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textasdasd
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula textadas
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula textasda
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textThis will be eula textasda
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textasdasd
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula textadas
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula textasda
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textThis will be eula textasda
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textasdasd
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula textadas
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula textasda
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textThis will be eula textasda
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textasdasd
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula textadas
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula textasda
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textThis will be eula textasda
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textasdasd
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula textadas
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula textasda
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textThis will be eula textasda
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textasdasd
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula textadas
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula textasda
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textThis will be eula textasda
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula textasdasd
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula textadas
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula textasda
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text
<h2>This will be eula text</h2>
This will be eula text
This will be eula text
This will be eula text
This will be eula text
This will be eula text"
)
    }
}
