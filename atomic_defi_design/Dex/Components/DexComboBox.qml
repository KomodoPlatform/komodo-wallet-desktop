import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"
import App 1.0

import Qaterial 1.0 as Qaterial

ComboBox {
    id: control

    Universal.theme: Style.dark_theme ? Universal.Dark : Universal.Light
    Universal.accent: Style.colorQtThemeAccent
    Universal.foreground: Style.colorQtThemeForeground
    Universal.background: Style.colorQtThemeBackground
    property alias border: bg_rect.border
    property alias radius: bg_rect.radius
    leftPadding: 20

    font.family: Style.font_family

    property color lineHoverColor: DexTheme.hoverColor
    property color mainBorderColor: control.pressed ? DexTheme.hoverColor  :  DexTheme.comboBoxBorderColor
    Behavior on lineHoverColor {
        ColorAnimation {
            duration: Style.animationDuration
        }
    }
    Behavior on mainBorderColor {
        ColorAnimation {
            duration: Style.animationDuration
        }
    }

    property string mainLineText: control.displayText
    property
    var dropdownLineText: m => textRole === "" ?
        m.modelData :
        !m.modelData ? m[textRole] : m.modelData[textRole]

    readonly property bool disabled: !enabled

    hoverEnabled: true

    // Main, selected text
    contentItem: RowLayout {
        property alias color: text.color

        DexLabel {
            id: text
            leftPadding: 12
            rightPadding: control.indicator.width + control.spacing

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            font: DexTypo.subtitle2

            text_value: control.mainLineText
            color: !control.enabled ? Qt.darker(DexTheme.foregroundColor, 0.6) : control.pressed ? Qt.darker(DexTheme.foregroundColor, 0.8) : DexTheme.foregroundColor
        }
    }


    // Main background
    background: DexRectangle {
        id: bg_rect
        implicitWidth: 120
        implicitHeight: 45
        color: !control.enabled ? DexTheme.buttonColorDisabled : DexTheme.comboBoxBackgroundColor
        border.color: control.mainBorderColor
        border.width: control.visualFocus ? 2 : 1
        radius: 20
    }

    // Dropdown itself
    popup: Popup {
        width: control.width

        topMargin: 20
        bottomMargin: 20

        padding: 1

        contentItem: DefaultListView {
            implicitHeight: contentHeight + 5 // Scrollbar appears if this extra space is not added
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            DefaultMouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }
        }

        background: AnimatedRectangle {
            color: DexTheme.comboBoxBackgroundColor
            border.color: DexTheme.comboBoxBorderColor
            radius: DexTheme.rectangleCornerRadius
        }
    }

    // Each dropdown item
    delegate: ItemDelegate {
        Universal.accent: control.lineHoverColor
        width: control.width
        highlighted: control.highlightedIndex === index

        contentItem: DexLabel {
            font: DexTypo.subtitle2
            text_value: control.dropdownLineText(model)
        }
    }

    // Dropdown arrow icon at right side
    indicator: Qaterial.Icon {
        x: control.mirrored ? control.padding : control.width - width - control.padding - 10
        y: control.topPadding + (control.availableHeight - height) / 2
        color: DexTheme.foregroundColor
        size: 16
        opacity: .9
        icon: Qaterial.Icons.chevronDown
    }

    DefaultMouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}