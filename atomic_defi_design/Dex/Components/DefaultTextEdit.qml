import QtQuick 2.15
import "../Constants"
import App 1.0

TextEdit
{
    id: control
    property string text_value
    property bool privacy: false
    property string linkURL: ""
    property string onCopyNotificationTitle: ""
    property string onCopyNotificationMsg: qsTr("copied to clipboard")

    font.family: Style.font_family
    font.pixelSize: Style.textSize
    text: privacy && General.privacy_mode ? General.privacy_text : text_value
    wrapMode: Text.WordWrap
    selectByMouse: true
    readOnly: true

    selectedTextColor: DexTheme.textSelectedColor
    selectionColor: DexTheme.textSelectionColor
    color: DexTheme.foregroundColor

    Behavior on color { ColorAnimation { duration: Style.animationDuration } }

    onLinkActivated: Qt.openUrlExternally(link)

    DefaultMouseArea
    {
        anchors.fill: parent
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
    }

    DefaultCopyIcon
    {
        id: copy_icon
        anchors.verticalCenter: parent.verticalCenter
        copyText: control.text_value
        notifyTitle: control.onCopyNotificationTitle
        notifyMsg: control.onCopyNotificationMsg
        x: control.implicitWidth + 6
        iconSize: 14
    }

    DefaultLinkIcon
    {
        anchors.verticalCenter: parent.verticalCenter
        linkURL: control.linkURL
        x: control.onCopyNotificationTitle == '' ? control.implicitWidth + 6 : control.implicitWidth + copy_icon.implicitWidth + 8
        iconSize: 14
    }
}