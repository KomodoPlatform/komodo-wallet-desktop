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
    property bool           collapsedAtConstruction:    false

    property alias          header:                     headerLoader.sourceComponent
    property alias          background:                 backgroundLoader.sourceComponent

    property int            margins:                    10
    property int            spacing:                    10
    property int            contentSpacing:             10

    default property alias  contentData:                content.data

    property bool           _collapsed:                 collapsable && collapsedAtConstruction

    function isCollapsed() { return _collapsed }

    // Background
    Loader
    {
        id: backgroundLoader
        anchors.fill: parent
        sourceComponent: defaultBackground
    }

    Column
    {
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

            visible: !root._collapsed

            width: parent.width
            height: parent.height - y

            spacing: root.contentSpacing
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
                icon: root._collapsed ? Qaterial.Icons.chevronUp : Qaterial.Icons.chevronDown

                DefaultMouseArea
                {
                    id: collapseButMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root._collapsed = !root._collapsed
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
