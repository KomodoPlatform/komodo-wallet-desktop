//! Qt Imports.
import QtQuick 2.15

//! Project Imports
import App 1.0
import "../Constants" as Dex
import Dex.Themes 1.0 as Dex

Text {
    property string text_value
    property bool privacy: false
    property bool monospace: false

    Behavior on color
    {
        ColorAnimation
        {
            duration: Style.animationDuration
        }
    }


    color: DexTheme.foregroundColor
    font: DexTypo.body1
    text: privacy && Dex.General.privacy_mode ? Dex.General.privacy_text : text_value
    wrapMode: Text.WordWrap

    onLinkActivated: Qt.openUrlExternally(link)
    linkColor: color

    DefaultMouseArea {
        anchors.fill: parent
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
    }
}

// 90% similar to DexLabel.qml
// This could be refactored down.
