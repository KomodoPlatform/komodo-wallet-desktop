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

    DexLabel {
        id: text

        clip: true
        Layout.fillWidth: true
        textFormat: TextEdit.AutoText

        color: DexTheme.foregroundColor

        Layout.preferredHeight: show_content ? contentHeight : 0
        Behavior on Layout.preferredHeight { SmoothedAnimation { id: expand_animation; duration: Constants.Style.animationDuration * 2; velocity: -1 } }

        opacity: show_content ? 1 : 0
        Behavior on opacity { SmoothedAnimation { duration: expand_animation.duration; velocity: -1 } }

        Qaterial.Icon {
            anchors.right: parent.right
            anchors.rightMargin: - 10
            icon: Qaterial.Icons.contentCopy
        }

        DexMouseArea {
            anchors.fill: parent
            enabled: control.copy
            onClicked: {
                Qaterial.Clipboard.text = control.text
                Qaterial.SnackbarManager.show(
                {
                    expandable: false,
                    text: "%1 ".arg(control.text) + qsTr("copied"),
                    timeout: Qaterial.Style.snackbar.longDisplayTime
                })
            }
        }
    }
}
