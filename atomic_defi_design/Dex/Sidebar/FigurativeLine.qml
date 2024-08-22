import QtQuick 2.12

import "../Components"
import "../Constants"
import Dex.Themes 1.0 as Dex

// FigurativeLine acts the same as Line but contains a figurative icon on the left of its label
Line
{
    property alias icon: _icon
    property string disabled_tt_text: ""

    DefaultImage
    {
        id: _icon
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 18
        height: 16
    }

    DefaultColorOverlay
    {
        anchors.fill: _icon
        source: _icon
        color: !_icon.enabled ? Dex.CurrentTheme.textDisabledColor :
               mouseArea.containsMouse && currentLineType !== type       ? Dex.CurrentTheme.sidebarLineTextHovered :
               currentLineType === type && type != Main.LineType.Support ? Dex.CurrentTheme.sidebarLineTextSelected :
                                                                           Dex.CurrentTheme.foregroundColor
    }

    DexTooltip
    {
        visible: mouseArea.containsMouse && disabled_tt_text
        delay: 500
        timeout: 5000
        text: disabled_tt_text
        font.pixelSize: Style.textSizeSmall4
    }
}
