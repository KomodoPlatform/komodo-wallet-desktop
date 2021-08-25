import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qaterial 1.0 as Qaterial
import "../Constants"
import App 1.0

ColumnLayout {
    id: control
    property alias title: title_text.text
    property alias field: input_field
    property alias save_button: save_button
    property alias hide_button: hide_button
    property alias hide_button_area: hide_button.mouse_area
    property bool copyable: false
    property bool hidable: false
    property var onReturn // function

    property alias remove_newline: input_field.remove_newline
    property bool hiding: true

    property bool saveable: false

    signal saved()
    signal copied()

    // Local
    function reset() {
        input_field.text = ''
    }

    RowLayout {
        TitleText {
            id: title_text
            Layout.alignment: Qt.AlignVCenter
            Qaterial.Icon {
                visible: control.copyable
                Layout.alignment: Qt.AlignVCenter
                x: title_text.implicitWidth + 10
                size: 16
                icon: Qaterial.Icons.contentCopy
                color: copyArea.containsMouse ? DexTheme.accentColor : DexTheme.foregroundColor
                DexMouseArea {
                    id: copyArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Qaterial.Clipboard.text = input_field.text
                        control.copied()
                    }
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: input_field.height + 5
        DefaultTextArea {
            id: input_field
            enabled: !saveable
            width: parent.width - 6
            rightPadding: 10
            anchors.centerIn: parent
            background: DexRectangle {
                color: DexTheme.dexBoxBackgroundColor
                opacity: .4
                radius: 8
            }
            HideFieldButton {
                id: hide_button
            }
        }
        DexAppButton {
            anchors.verticalCenter: parent.verticalCenter
            id: save_button
            button_type: input_field.enabled ? "danger" : "primary"
            anchors.right: parent.right
            anchors.rightMargin: 8
            text: input_field.enabled ? qsTr("Save") : qsTr("Edit")
            visible: saveable
            onClicked: {
                if(input_field.enabled) saved()
                input_field.enabled = !input_field.enabled
            }
            font.pixelSize: Style.textSizeSmall
            minWidth: 0
            height: 20
        }
    }

    
}


