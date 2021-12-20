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

    Behavior on color
    {
        ColorAnimation
        {
            duration: Style.animationDuration
        }
    }

    font: Qt.font
    ({
        pixelSize: 14,
        letterSpacing: 0.25,
        weight: Font.Normal
    })

    color: enabled ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.textDisabledColor

    text: privacy && Dex.General.privacy_mode ? Dex.General.privacy_text : text_value
    wrapMode: Text.WordWrap

    onLinkActivated: Qt.openUrlExternally(link)
    linkColor: color
}
