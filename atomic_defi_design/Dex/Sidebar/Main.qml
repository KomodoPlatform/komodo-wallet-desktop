import QtQuick 2.12

import "../Components"
import "../Constants"
import Dex.Themes 1.0 as Dex

Item
{
    id: root

    enum LineType
    {
        None,
        Portfolio,
        Wallet,
        DEX,         // DEX == Trading page
        Addressbook,
        Support
    }

    property bool   isExpanded: true
    property real   lineHeight: 44

    property var    _currentLineType: Main.LineType.Portfolio
    property alias  _selectionCursor: _selectionCursor

    signal lineSelected(var lineType)
    signal settingsClicked()
    signal privacySwitched(var checked)

    width: isExpanded ? 200 : 80
    height: parent.height

    // Background Rectangle
    Rectangle
    {
        anchors.fill: parent
        color: Dex.CurrentTheme.sidebarBgColor
    }

    // Animation when changing width.
    Behavior on width
    {
        NumberAnimation { duration: 300 }
    }

    // Selection Cursor
    AnimatedRectangle
    {
        id: _selectionCursor

        y: center.y
        anchors.right: parent.right
        radius: 18
        width: isExpanded ? 185 : 80
        height: lineHeight

        opacity: .7

        gradient: Gradient
        {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.125; color: Dex.CurrentTheme.sidebarCursorStartColor }
            GradientStop { position: 0.900; color: Dex.CurrentTheme.sidebarCursorEndColor }
        }

        Behavior on y
        {
            NumberAnimation { duration: 180 }
        }
    }

    Top
    {
        id: top
        width: parent.width
        height: 180
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    Center
    {
        id: center
        width: parent.width
        anchors.top: top.bottom
        anchors.topMargin: 69.5
        onLineSelected:
        {
            if (_currentLineType === lineObj.type)
                return;
            _currentLineType = lineObj.type;
            root.lineSelected(lineObj.type);
            _selectionCursor.y = y + lineObj.y;
        }
    }

    Bottom
    {
        id: botton
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 62

        onSupportLineSelected:
        {
            if (_currentLineType === lineObj.type)
                return;
            _currentLineType = lineObj.type;
            root.lineSelected(lineObj.type);
            _selectionCursor.y = y + lineObj.y;
        }
        onSettingsClicked: root.settingsClicked()
    }

    VerticalLine
    {
        height: parent.height
        anchors.right: parent.right
    }
}
