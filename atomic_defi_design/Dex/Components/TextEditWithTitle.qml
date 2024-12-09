import QtQuick 2.15
import QtQuick.Layouts 1.15

import Qaterial 1.0 as Qaterial

import "../Constants" as Constants
import App 1.0
import Dex.Themes 1.0 as Dex

ComponentWithTitle
{
    id: control

    property alias  label: _text
    property alias  text: _text.text_value
    property alias  value_color: _text.color
    property alias  privacy: _text.privacy
    property bool   copy: false
    property bool   monospace: false
    property string linkURL: ""
    property string onCopyNotificationTitle: ""
    property string onCopyNotificationMsg: qsTr("copied to clipboard")

    Row
    {
        Layout.fillWidth: true

        DexLabel
        {
            id: _text

            width: implicitWidth > parent.width * 0.9 ? parent.width * 0.9 : implicitWidth

            clip: true
            textFormat: TextEdit.AutoText
            opacity: show_content ? 1 : 0
            wrapMode: Text.WordWrap
            monospace: control.monospace
            rightPadding: 5
            Behavior on opacity { SmoothedAnimation { duration: expand_animation.duration; velocity: -1 } }
            Behavior on Layout.preferredHeight { SmoothedAnimation { id: expand_animation; duration: Constants.Style.animationDuration * 2; velocity: -1 } }
        }

        DefaultCopyIcon
        {
            id: copyIcon
            visible: control.onCopyNotificationTitle !== ""
            copyText: control.text
            notifyTitle: control.onCopyNotificationTitle
            notifyMsg: control.onCopyNotificationMsg
            iconSize: 14
        }

        DefaultLinkIcon
        {
            visible: control.linkURL !== ""
            linkURL: control.linkURL
            x: copyIcon.visible ? _text.width + 18 : _text.width + 28
            iconSize: 14
        }

        Item { Layout.fillWidth: true }
    }
}
