import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qaterial 1.0 as Qaterial
import "../Constants" as Constants
import App 1.0

ComponentWithTitle {
    id: control
    property alias text: text.text_value
    property alias value_color: text.color
    property alias privacy: text.privacy
    property bool copy: false

    RowLayout {
        Layout.fillWidth: true

        DexLabel {
            id: text

            clip: true
            textFormat: TextEdit.AutoText
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: show_content ? contentHeight : 0
            Behavior on Layout.preferredHeight { SmoothedAnimation { id: expand_animation; duration: Constants.Style.animationDuration * 2; velocity: -1 } }
            color: DexTheme.foregroundColor

            

            opacity: show_content ? 1 : 0
            Behavior on opacity { SmoothedAnimation { duration: expand_animation.duration; velocity: -1 } }

        }

        Qaterial.Icon {
            visible: control.copy
            Layout.alignment: Qt.AlignVCenter
            x: text.implicitWidth + 10
            size: 16
            icon: Qaterial.Icons.contentCopy
            color: copyArea.containsMouse ? DexTheme.accentColor : DexTheme.foregroundColor
            DexMouseArea {
                id: copyArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    Qaterial.Clipboard.text = control.text
                    app.notifyCopy(qsTr("Swap ID"), qsTr("copied to clipboard"))
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
