import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import Dex.Themes 1.0 as Dex


ToolTip
{
    id: control

    contentItem: DexLabel
    {
        text: control.text
        font: control.font
        color: Dex.CurrentTheme.foregroundColor
    }

    background: FloatingBackground
    {}
}