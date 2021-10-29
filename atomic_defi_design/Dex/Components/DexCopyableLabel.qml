//! Qt Imports.
import QtQuick 2.12
import QtQuick.Controls 2.1 //> TextField

//! 3rdParty Imports.
import Qaterial 1.0 as Qaterial //> Icon

//! Project Imports.
import App 1.0 //> DexTheme

// DexCopyableLabel is a label which content can be copied to clipboard with the help of a copy icon right to te text.
// It is not editable by users.
Item
{
    id: control

    property alias  text: label.text

    property string onCopyNotificationTitle
    property string onCopyNotificationMsg

    implicitWidth: label.width + copyIcon.width + copyIcon._leftMargin
    implicitHeight: label.height

    DexLabel
    {
        id: label
        font: Qt.font({
            pixelSize: 13,
            letterSpacing: 0.25,
            weight: Font.Normal
        })
        color: DexTheme.foregroundColor
    }

    Qaterial.Icon
    {
        id: copyIcon

        property int _leftMargin: 10

        anchors.left: label.right
        anchors.leftMargin: _leftMargin
        size: 16
        icon: Qaterial.Icons.contentCopy
        color: copyArea.containsMouse ? DexTheme.accentColor : DexTheme.foregroundColor
        DexMouseArea
        {
            id: copyArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked:
            {
                Qaterial.Clipboard.text = label.text
                app.notifyCopy(onCopyNotificationTitle, onCopyNotificationMsg)
            }
        }
    }
}
