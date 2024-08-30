//! Qt Imports.
import QtQuick 2.15

//! Project Imports
import App 1.0
import "../Constants" as Dex
import Dex.Themes 1.0 as Dex

Text
{
    property string text_value
    property bool   privacy: false
    property bool   monospace: false

    Behavior on color
    {
        ColorAnimation
        {
            duration: Style.animationDuration
        }
    }

    text: privacy && Dex.General.privacy_mode ? Dex.General.privacy_text : text_value
    font: monospace ? Dex.DexTypo.monoSmall : Dex.DexTypo.body2
    color: enabled ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.textDisabledColor
    wrapMode: Text.WordWrap
    onLinkActivated: Qt.openUrlExternally(link)
    linkColor: color
}
