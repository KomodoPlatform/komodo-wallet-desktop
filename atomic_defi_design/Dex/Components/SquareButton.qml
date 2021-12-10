import QtQuick 2.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial
import Dex.Themes 1.0 as Dex

Qaterial.SquareButton
{
    elevation: 0
    foregroundColor: hovered ? Qt.lighter(Dex.CurrentTheme.foregroundColor) : Dex.CurrentTheme.foregroundColor

    HoverHandler
    {
        cursorShape: "PointingHandCursor"
    }
}