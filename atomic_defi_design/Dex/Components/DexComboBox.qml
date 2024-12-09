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

    property alias  radius: bg_rect.radius
    property int    dropDownMaxHeight: 450
    property color  comboBoxBackgroundColor: Dex.CurrentTheme.comboBoxBackgroundColor
    property color  mainBackgroundColor: Dex.CurrentTheme.comboBoxBackgroundColor
    property color  popupBackgroundColor: Dex.CurrentTheme.comboBoxBackgroundColor
    property color  highlightedBackgroundColor: Dex.CurrentTheme.comboBoxDropdownItemHighlightedColor
    property string mainLineText: control.displayText
    property var    dropdownLineText: m => textRole === "" ?
                                        m.modelData :
                                        !m.modelData ? m[textRole] : m.modelData[textRole]

    font.family: Style.font_family
    hoverEnabled: true

    // Main, selected text
    contentItem: Item
    {
        DexLabel
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 13
            width: parent.width - anchors.leftMargin
            font: DexTypo.subtitle2
            text_value: control.mainLineText
            elide: Text.ElideRight
        }
    }

    // Main background
    background: FloatingBackground
    {
        id: bg_rect
        implicitWidth: 150
        implicitHeight: 45
        color: control.mainBackgroundColor
        radius: 20
    }

    // Dropdown itself
    popup: Popup
    {
        width: control.width
        leftPadding: 0
        rightPadding: 0
        topPadding: 16
        bottomPadding: 16

        contentItem: DefaultListView
        {
            id: _list
            model: control.popup.visible ? control.delegateModel : null
            implicitHeight: contentHeight > control.dropDownMaxHeight ? control.dropDownMaxHeight : contentHeight
            currentIndex: control.highlightedIndex

            ScrollBar.vertical: ScrollBar
            {
                visible: _list.contentHeight > control.dropDownMaxHeight
                anchors.right: _list.right
                anchors.rightMargin: 2
                width: 7
                background: DefaultRectangle
                {
                    radius: 12
                    color: Dex.CurrentTheme.scrollBarBackgroundColor
                }
                contentItem: DefaultRectangle
                {
                    radius: 12
                    color: Dex.CurrentTheme.scrollBarIndicatorColor
                }
            }

            DefaultMouseArea
            {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }
        }

        background: Rectangle
        {
            radius: control.radius
            color: control.popupBackgroundColor
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

        background: Rectangle
        {
            anchors.fill: combo_item
            color: combo_item.highlighted ? Dex.CurrentTheme.comboBoxDropdownItemHighlightedColor : Dex.CurrentTheme.comboBoxBackgroundColor
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

    DefaultMouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
