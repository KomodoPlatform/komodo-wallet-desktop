import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15

import Qaterial 1.0 as Qaterial

import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

ComboBox
{
    id: control

    property alias radius: bg_rect.radius
    readonly property bool disabled: !enabled
    property int dropDownMaxHeight: 450
    property color comboBoxBackgroundColor: Dex.CurrentTheme.comboBoxBackgroundColor
    property color mainBackgroundColor: Dex.CurrentTheme.floatingBackgroundColor
    property color popupBackgroundColor: Dex.CurrentTheme.floatingBackgroundColor
    property color highlightedBackgroundColor: Dex.CurrentTheme.comboBoxDropdownItemHighlightedColor
    property string mainLineText: control.displayText
    property
    var dropdownLineText: m => textRole === "" ?
        m.modelData :
        !m.modelData ? m[textRole] : m.modelData[textRole]

    font.family: Style.font_family
    hoverEnabled: true

    // Combobox Dropdown Button Background
    background: DexRectangle
    {
        id: bg_rect
        implicitWidth: 150
        implicitHeight: 45
        color: comboBoxBackgroundColor
        radius: 20
    }

    // Main, selected text
    contentItem: Item
    {
        anchors.fill: parent

        DexLabel
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 15
            width: parent.width

            font: DexTypo.subtitle2
            text_value: control.mainLineText
            elide: Text.ElideRight
        }
    }

    // Each dropdown item
    delegate: ItemDelegate
    {
        id: combo_item
        width: control.width
        highlighted: control.highlightedIndex === index

        contentItem: DexLabel
        {
            width: control.width
            font: DexTypo.subtitle2
            text_value: control.dropdownLineText(model)
            elide: Text.ElideRight
        }

        // Dropdown Item background
        background: DexRectangle {
            anchors.fill: combo_item
            color: combo_item.highlighted ? highlightedBackgroundColor : mainBackgroundColor
        }
    }

    // Dropdown arrow icon at right side
    indicator: Column
    {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 8
        spacing: -12

        Qaterial.Icon
        {
            width: 20
            height: 20
            color: Dex.CurrentTheme.comboBoxArrowsColor
            icon: Qaterial.Icons.chevronUp
        }

        Qaterial.Icon
        {
            width: 20
            height: 20
            color: Dex.CurrentTheme.comboBoxArrowsColor
            icon: Qaterial.Icons.chevronDown
        }
    }

    // Dropdown itself
    popup: Popup
    {
        id: combo_popup
        readonly property double max_height: 450

        width: control.width
        height: _list.contentHeight > control.dropDownMaxHeight ? control.dropDownMaxHeight : _list.contentHeight
        leftPadding: 0
        rightPadding: 0
        topPadding: 16
        bottomPadding: 16
        padding: 1

        contentItem: DexListView
        {
            id: _list
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            DexMouseArea
            {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }
        }

        background: DexRectangle
        {
            width: parent.width
            height: parent.height
            radius: control.radius
            color: control.popupBackgroundColor
            colorAnimation: false
            border.width: 1
        }
    }

    DexMouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
