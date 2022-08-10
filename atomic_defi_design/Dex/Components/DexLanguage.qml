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

    property color highlightedBackgroundColor: Dex.CurrentTheme.comboBoxDropdownItemHighlightedColor
    property color mainBackgroundColor: Dex.CurrentTheme.floatingBackgroundColor


    displayText: API.app.settings_pg.lang
    leftPadding: 5

    delegate: ItemDelegate
    {
        id: combo_item
        width: control.width
        height: 30
        highlighted: control.highlightedIndex === index

        contentItem: RowLayout
        {
            anchors.fill: parent
            spacing: -13

            DexImage
            {
                id: image
                Layout.preferredHeight: 14
                source: General.image_path + "lang/" + modelData + ".png"
            }

            DexLabel
            {
                text: modelData

            }
        }

        // Dropdown Item background
        background: DexRectangle {
            anchors.fill: combo_item
            color: combo_item.highlighted ? highlightedBackgroundColor : mainBackgroundColor
        }

        onClicked:
        {
            if (modelData !== API.app.settings_pg.lang)
            {
                API.app.settings_pg.lang = modelData
            }
        }
    }

    contentItem: Text
    {
        anchors.fill: parent
        leftPadding: 0
        rightPadding: control.indicator.width + control.spacing

        //text: control.displayText
        font: control.font
        color: control.pressed ? "#17a81a" : "#21be2b"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        DexImage
        {
            id: image
            height: 12
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            source: General.image_path + "lang/" + control.displayText + ".png"
        }
    }

    DexMouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}