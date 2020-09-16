import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.impl 2.12
import QtQuick.Controls.Universal 2.12
import "../Constants"

ComboBox {
    id: control

    font.family: Style.font_family

    property color lineHoverColor: Style.colorTheme5
    property color mainBorderColor: control.pressed ? Style.colorTheme8 : Style.colorTheme5

    property string mainLineText: control.displayText
    property var dropdownLineText: m => textRole === "" ? m.modelData : m.modelData[textRole]


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

            text_value: API.get().settings_pg.empty_string + (control.mainLineText)
            color: !control.enabled ? Style.colorTextDisabled : control.pressed ? Style.colorText2 : Style.colorText
        }
    }


    // Main background
    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: !control.enabled ? Style.colorTheme5 : control.hovered ? Style.colorTheme7 : Style.colorTheme9
        border.color: control.mainBorderColor
        border.width: control.visualFocus ? 2 : 1
        radius: 16
    }

    // Dropdown itself
    popup: Popup {
        y: control.height
        width: control.width
        height: Math.min(contentItem.implicitHeight, control.Window.height * - 80)

        padding: 1

        contentItem: DefaultListView {
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
        }

        background: Rectangle {
            color: Style.colorTheme9
            border.color: control.mainBorderColor
            radius: 16
        }
    }

    // Each dropdown item
    delegate: ItemDelegate {
        Universal.accent: control.lineHoverColor
        width: control.width
        highlighted: control.highlightedIndex === index

        contentItem: DefaultText {
            text_value: API.get().settings_pg.empty_string + (control.dropdownLineText(model))
            color: Style.colorText
        }
    }

    // Dropdown arrow icon at right side
    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control

            function onPressedChanged() { canvas.requestPaint() }
            function onDisabledChanged() { canvas.requestPaint() }
            function onHoveredChanged() { canvas.requestPaint() }
        }

        onPaint: {
            context.reset()
            context.moveTo(0, 0)
            context.lineTo(width, 0)
            context.lineTo(width / 2, height)
            context.closePath()
            context.fillStyle = control.contentItem.color
            context.fill()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

