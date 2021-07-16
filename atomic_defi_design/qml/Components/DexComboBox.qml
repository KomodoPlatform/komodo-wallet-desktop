import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"

ComboBox {
    id: control

    Universal.theme: Style.dark_theme ? Universal.Dark : Universal.Light
    Universal.accent: Style.colorQtThemeAccent
    Universal.foreground: Style.colorQtThemeForeground
    Universal.background: Style.colorQtThemeBackground
    property alias border: bg_rect.border
    property alias radius: bg_rect.radius

    font.family: Style.font_family

    property color lineHoverColor: theme.hightlightColor
    property color mainBorderColor: control.pressed ? theme.surfaceColor : theme.hightlightColor
    Behavior on lineHoverColor { ColorAnimation { duration: Style.animationDuration } }
    Behavior on mainBorderColor { ColorAnimation { duration: Style.animationDuration } }

    property string mainLineText: control.displayText
    property var dropdownLineText: m => textRole === "" ?
                                       m.modelData :
                                       !m.modelData ? m[textRole] : m.modelData[textRole]

    readonly property bool disabled: !enabled

    hoverEnabled: true

    // Main, selected text
    contentItem: RowLayout {
        property alias color: text.color

        DefaultText {
            id: text
            leftPadding: 12
            rightPadding: control.indicator.width + control.spacing

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

            text_value: control.mainLineText
            color: !control.enabled ? Qt.darker(theme.foregroundColor, 0.6) : control.pressed ? Qt.darker(theme.foregroundColor, 0.8) : theme.foregroundColor
        }
    }


    // Main background
    background: AnimatedRectangle {
        id: bg_rect
        implicitWidth: 120
        implicitHeight: 40
        color: !control.enabled ? theme.hightlightColor : control.hovered ? theme.backgroundColor : theme.dexBoxBackgroundColor
        border.color: control.mainBorderColor
        border.width: control.visualFocus ? 2 : 1
        radius: Style.rectangleCornerRadius
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
            color: theme.dexBoxBackgroundColor
            border.color: theme.rectangleBorderColor
            radius: theme.rectangleCornerRadius
        }
    }

    // Each dropdown item
    delegate: ItemDelegate {
        Universal.accent: control.lineHoverColor
        width: control.width
        highlighted: control.highlightedIndex === index

        contentItem: DefaultText {
            text_value: control.dropdownLineText(model)
        }
    }

    // Dropdown arrow icon at right side
    indicator: ColorImage {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        color: theme.rectangleBorderColor
        defaultColor: control.contentItem.color
        scale: .8
        source: "qrc:/qt-project.org/imports/QtQuick/Controls.2/images/double-arrow.png"
    }

    DefaultMouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
