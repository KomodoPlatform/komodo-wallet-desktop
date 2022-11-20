import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"
import "../Components"
import App 1.0
import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex

RowLayout
{
    id: control
    property string text_value: ""
    property int font_size: Style.textSize
    property int text_box_width: 500
    property bool privacy: false
    property bool align_left: false
    property string linkURL: ""
    property string onCopyNotificationTitle: ""
    property string onCopyNotificationMsg: qsTr("copied to clipboard")
    Layout.fillWidth: true

    Item { Layout.fillWidth: !align_left }

    Dex.Rectangle
    {
        width: text_box_width
        height: 30
        color: Dex.CurrentTheme.buttonColorEnabled

        RowLayout
        {
            spacing: 4
            anchors.fill: parent
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: !align_left ? parent.horizontalCenter : undefined

            Item { width: 6 }

            TextEdit
            {
                font.family: Style.font_family
                font.pixelSize: font_size
                text: privacy && General.privacy_mode ? General.privacy_text : text_value
                wrapMode: Text.WordWrap
                selectByMouse: true
                readOnly: true

                selectedTextColor: DexTheme.textSelectedColor
                selectionColor: DexTheme.textSelectionColor
                color: DexTheme.foregroundColor
            }

            Item { Layout.fillWidth: true }

            DefaultCopyIcon
            {
                id: copy_icon
                visible: control.onCopyNotificationTitle !== ""
                copyText: control.text_value
                notifyTitle: control.onCopyNotificationTitle
                notifyMsg: control.onCopyNotificationMsg
                iconSize: font_size
            }

            DefaultLinkIcon
            {
                visible: control.linkURL !== ""
                linkURL: control.linkURL
                iconSize: font_size
            }

            Item { width: 6 }
        }

        DefaultMouseArea
        {
            anchors.fill: parent
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            acceptedButtons: Qt.NoButton
        }
    }

    Item { Layout.fillWidth: true }
}