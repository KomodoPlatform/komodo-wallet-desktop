import QtQuick 2.15
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

Rectangle
{
    property bool colorAnimation: true
    Behavior on color { ColorAnimation { duration: colorAnimation ? Style.animationDuration : 0; } }

    color: Dex.CurrentTheme.backgroundColor
}
