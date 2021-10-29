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

    property alias border: bg_rect.border
    property alias radius: bg_rect.radius
    property color lineHoverColor: DexTheme.hoverColor
    property color mainBorderColor: Dex.CurrentTheme.accentColor
    property color mainBackgroundColor: Dex.CurrentTheme.floatingBackgroundColor
    property color dropdownBackgroundColor: Dex.CurrentTheme.floatingBackgroundColor

    property string mainLineText: control.displayText
    property var dropdownLineText: m => textRole === "" ?
        m.modelData :
        !m.modelData ? m[textRole] : m.modelData[textRole]

    readonly property bool disabled: !enabled

    leftPadding: 20
    font.family: Style.font_family

    Behavior on lineHoverColor
    {
        ColorAnimation { duration: Style.animationDuration }
    }
    Behavior on mainBorderColor
    {
        ColorAnimation { duration: Style.animationDuration }
    }

    hoverEnabled: true

    // Main, selected text
    contentItem: RowLayout
    {
        property alias color: text.color

        DefaultText
        {
            id: text
            leftPadding: 6
            rightPadding: control.indicator.width + control.spacing

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
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
        border.color: control.mainBorderColor
        border.width: control.visualFocus ? 2 : 1
        color: control.mainBackgroundColor
        radius: 20
    }

    // Dropdown itself
    popup: Popup
    {
        width: control.width

        topMargin: 20
        bottomMargin: 20

        padding: 1

        contentItem: DefaultListView
        {
            implicitHeight: contentHeight + 5 // Scrollbar appears if this extra space is not added
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            DefaultMouseArea
            {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }
        }

        background: Rectangle { color: control.dropdownBackgroundColor }
    }

    // Each dropdown item
    delegate: ItemDelegate
    {
        Universal.accent: control.lineHoverColor
        width: control.width
        highlighted: control.highlightedIndex === index

        contentItem: DexLabel
        {
            font: DexTypo.subtitle2
            text_value: control.dropdownLineText(model)
        }
    }

    // Dropdown arrow icon at right side
    indicator: Qaterial.Icon
    {
        x: control.mirrored ? control.padding : control.width - width - control.padding - 10
        y: control.topPadding + (control.availableHeight - height) / 2
        color: Dex.CurrentTheme.foregroundColor
        size: 16
        opacity: .9
        icon: Qaterial.Icons.chevronDown
    }

    DefaultMouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
