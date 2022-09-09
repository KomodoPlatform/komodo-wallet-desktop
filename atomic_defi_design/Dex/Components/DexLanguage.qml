import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Universal 2.15

import QtGraphicalEffects 1.0

import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

DexComboBox
{
    id: control
    model: API.app.settings_pg.get_available_langs()
    height: 50

    displayText: API.app.settings_pg.lang
    leftPadding: 5

    // Each dropdown item
    delegate: ItemDelegate
    {
        id: combo_item
        width: control.width
        height: 35
        highlighted: control.highlightedIndex === index

        contentItem: RowLayout
        {
            anchors.fill: parent
            spacing: -25

            DexImage
            {
                id: image
                Layout.preferredHeight: 25
                source: General.image_path + "lang/" + modelData + ".png"
            }

            DexLabel
            {
                text: modelData
            }
        }

        background: Rectangle
        {
            anchors.fill: combo_item
            radius: 6
            color: combo_item.highlighted ? Dex.CurrentTheme.comboBoxDropdownItemHighlightedColor : Dex.CurrentTheme.comboBoxBackgroundColor
        }

        onClicked:
        {
            if (modelData !== API.app.settings_pg.lang)
            {
                API.app.settings_pg.lang = modelData
            }
        }
    }

    // Main, selected item
    contentItem: Text
    {
        anchors.fill: parent
        leftPadding: 0
        rightPadding: control.indicator.width + control.spacing
        verticalAlignment: Text.AlignVCenter

        DexImage
        {
            id: image
            height: 25
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            source: General.image_path + "lang/" + control.displayText + ".png"
        }
    }

    background: FloatingBackground
    {
        radius: 20
        color: Dex.CurrentTheme.comboBoxBackgroundColor
    }

    DexMouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}