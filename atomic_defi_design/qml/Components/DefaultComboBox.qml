import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12
import "../Constants"

ComboBox {
    id: control

    font.family: Style.font_family

    readonly property bool disabled: !enabled

    // Main, selected text
    contentItem: Text {
        leftPadding: 12
        rightPadding: control.indicator.width + control.spacing

        text: control.displayText
        font: control.font
        color: !control.enabled ? Style.colorTextDisabled : control.pressed ? Style.colorText2 : Style.colorText
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // Main background
    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: control.enabled ? Style.colorTheme9 : Style.colorTheme5
        border.color: control.pressed ? Style.colorTheme8 : Style.colorTheme5
        border.width: control.visualFocus ? 2 : 1
        radius: 16
    }

    // Dropdown itself
    popup: Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
        }

        background: Rectangle {
            color: Style.colorTheme9
            border.color: Style.colorTheme5
            radius: 16
        }
    }

    // Each dropdown item
    delegate: ItemDelegate {
        width: control.width
        contentItem: Text {
            text: model.ticker + " (" + model.balance + ")"
            color: Style.colorText
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: control.highlightedIndex === index
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
        }

        onPaint: {
            context.reset()
            context.moveTo(0, 0)
            context.lineTo(width, 0)
            context.lineTo(width / 2, height)
            context.closePath()
            context.fillStyle = control.disabled ? Style.colorTextDisabled : control.pressed ? Style.colorText2 : Style.colorText
            context.fill()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

