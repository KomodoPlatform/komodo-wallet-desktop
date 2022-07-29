import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex
import "../Constants"

Item
{
    id: root

    property string         title:                      "Widget"

    property bool           collapsable:                true
    property bool           collapsed:                  false

    property bool           resizable:                  true

    property alias          header:                     headerLoader.sourceComponent
    property alias          background:                 backgroundLoader.sourceComponent

    property int            margins:                    10
    property int            spacing:                    10
    property int            contentSpacing:             10

    property int            collapsedHeight:            70
    property int            minHeight:                  collapsedHeight
    property int            maxHeight:                  -1
    property int            currentHeight:              minHeight

    default property alias  contentData:                content.data

    function isCollapsed() { return collapsed }

    clip: true

    // Background
    Loader
    {
        id: backgroundLoader
        anchors.fill: parent
        sourceComponent: defaultBackground
    }

    // Header + Content
    Column
    {
        id: column

        anchors.fill: parent
        anchors.margins: root.margins

        spacing: root.spacing

        // Header
        Loader
        {
            id: headerLoader
            sourceComponent: defaultHeader
            width: parent.width
        }

        // Content
        ColumnLayout
        {
            id: content

            visible: !root.collapsed

            width: parent.width
            height: parent.height - y

            spacing: root.contentSpacing
        }
    }

    // Resize area
    MouseArea
    {
        enabled: resizable && !collapsed
        visible: enabled

        anchors.bottom: root.bottom
        height: 5
        width: root.width

        cursorShape: Qt.SizeVerCursor

        drag.target: this
        drag.axis: Drag.YAxis
        onMouseYChanged:
        {
            if (drag.active)
            {
                let oldHeight = root.height

                if (root.parent.availableHeight && root.parent.availableHeight <= 0 && mouseY > 0)
                    return
                if (root.parent.availableHeight && root.parent.availableHeight < mouseY)
                    root.height += root.parent.availableHeight
                else
                    root.height += mouseY

                if (root.maxHeight >= 0 && root.height > root.maxHeight)
                    root.height = root.maxHeight
                else if (root.minHeight >= 0 && root.height < root.minHeight)
                    root.height = root.minHeight
            }
        }
    }

    // Header Component
    Component
    {
        id: defaultHeader

        RowLayout
        {
            DefaultText { text: root.title; font: DexTypo.subtitle1 }
            Item { Layout.fillWidth: true }
            Qaterial.Icon
            {
                visible: root.collapsable
                width: 20
                height: 20
                color: collapseButMouseArea.containsMouse ? Dex.CurrentTheme.foregroundColor2 : Dex.CurrentTheme.foregroundColor
                icon: root.collapsed ? Qaterial.Icons.chevronUp : Qaterial.Icons.chevronDown

                DefaultMouseArea
                {
                    id: collapseButMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.collapsed = !root.collapsed
                }
            }
        }
    }

    // Background Component
    Component
    {
        id: defaultBackground

        Rectangle
        {
            radius: 10
            color: Dex.CurrentTheme.floatingBackgroundColor
        }
    }
}
