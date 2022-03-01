import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qaterial 1.0 as Qaterial
import "../Constants" as Constants
import App 1.0

Qaterial.Icon
{
    property int iconSize: 14
    property string tooltipText: ""
    property var iconColor: Style.colorText2
    property var iconColorHover: DexTheme.foregroundColor

    icon: Qaterial.Icons.alert
    size: iconSize
    anchors.left: parent.left
    anchors.leftMargin: iconSize / 2
    anchors.rightMargin: iconSize / 2
    anchors.verticalCenter: parent.verticalCenter
    color: alertArea.containsMouse ? iconColorHover : iconColor

    DexMouseArea
    {
        id: alertArea
        anchors.fill: parent
        hoverEnabled: true
    }

    DefaultTooltip
    {
        visible: alertArea.containsMouse
        text: tooltipText
    }
}