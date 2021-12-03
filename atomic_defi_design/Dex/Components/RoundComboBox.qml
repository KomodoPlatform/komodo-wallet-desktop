import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Universal 2.15

import Qaterial 1.0 as Qaterial

import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

ComboBox
{
    id: control

    property alias radius: bg_rect.radius
    property color lineHoverColor: DexTheme.hoverColor
    property color mainBackgroundColor: Dex.CurrentTheme.floatingBackgroundColor
    property int dropDownMaxHeight: 300
    property color dropdownBackgroundColor: Dex.CurrentTheme.floatingBackgroundColor
    property
    var dropdownLineText: m => textRole === "" ?
        m.modelData :
        !m.modelData ? m[textRole] : m.modelData[textRole]
    property string mainLineText: control.displayText

    readonly property bool disabled: !enabled

    font.family: Style.font_family

    Behavior on lineHoverColor
    {
        ColorAnimation
        {
            duration: Style.animationDuration
        }
    }

    hoverEnabled: true

    // Main, selected text
    contentItem: Item
    {
        anchors.fill: parent
        DefaultText
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 13
            font: DexTypo.subtitle2
            text_value: control.mainLineText
        }
    }


    // Main background
    background: FloatingBackground
    {
        id: bg_rect
        implicitWidth: 120
        implicitHeight: 45
        color: control.mainBackgroundColor
        radius: 18
    }

    // Dropdown itself
    popup: Popup
    {
        width: control.width
        height: _list.contentHeight + 32 // > control.dropDownMaxHeight ? control.dropDownMaxHeight : _list.contentHeight
        leftPadding: 0
        rightPadding: 0
        topPadding: 16
        bottomPadding: 16

        contentItem: DefaultListView
        {
            id: _list
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollBar.vertical: ScrollBar
            {
                anchors.right: _list.right
                anchors.rightMargin: 2
                width: 7
                visible: false
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
            color: control.dropdownBackgroundColor
        }
    }

    // Each dropdown item
    delegate: ItemDelegate
    {
        Universal.accent: Dex.CurrentTheme.comboBoxDropdownItemHighlightedColor
        width: control.width
        highlighted: control.highlightedIndex === index

        contentItem: DexLabel
        {
            font: DexTypo.subtitle2
            text_value: control.dropdownLineText(model)
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