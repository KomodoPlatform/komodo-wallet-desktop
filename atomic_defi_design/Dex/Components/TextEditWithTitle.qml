import QtQuick 2.15
import QtQuick.Layouts 1.15

import Qaterial 1.0 as Qaterial

import "../Constants" as Constants
import App 1.0
import Dex.Themes 1.0 as Dex

ComponentWithTitle
{
    id: control

    property alias  text: text.text_value
    property alias  value_color: text.color
    property alias  privacy: text.privacy
    property bool   copy: false
    property string onCopyNotificationTitle: qsTr("Swap ID")
    property string onCopyNotificationMsg: qsTr("copied to clipboard")

    RowLayout
    {
        Layout.fillWidth: true

        DefaultText
        {
            id: text

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: show_content ? contentHeight : 0

            clip: true
            textFormat: TextEdit.AutoText
            opacity: show_content ? 1 : 0
            wrapMode: Text.WrapAnywhere

            Behavior on opacity { SmoothedAnimation { duration: expand_animation.duration; velocity: -1 } }
            Behavior on Layout.preferredHeight { SmoothedAnimation { id: expand_animation; duration: Constants.Style.animationDuration * 2; velocity: -1 } }
        }

        Qaterial.Icon
        {
            visible: control.copy

            Layout.alignment: Qt.AlignVCenter

            size: 16
            icon: Qaterial.Icons.contentCopy
            color: copyArea.containsMouse ? Dex.CurrentTheme.foregroundColor2 : Dex.CurrentTheme.foregroundColor

            DefaultMouseArea
            {
                id: copyArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked:
                {
                    Qaterial.Clipboard.text = control.text
                    app.notifyCopy(onCopyNotificationTitle, onCopyNotificationMsg)
                }
            }
        }
    }
}
