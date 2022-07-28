import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qaterial 1.0 as Qaterial
import App 1.0

Qaterial.Icon
{
    property int iconSize: 14
    property string copyText: ""
    property string notifyTitle: ""
    property string notifyMsg: qsTr("copied to clipboard")

    Layout.alignment: Qt.AlignVCenter

    size: iconSize
    icon: Qaterial.Icons.contentCopy
    color: copyArea.containsMouse ? Style.colorText2 : DexTheme.foregroundColor

    DexMouseArea
    {
        id: copyArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked:
        {
            Qaterial.Clipboard.text = control.text
            app.notifyCopy(notifyTitle, notifyMsg)
        }
    }
}