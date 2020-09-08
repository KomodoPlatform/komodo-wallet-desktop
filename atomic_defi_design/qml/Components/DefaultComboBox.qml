import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12
import "../Constants"

ComboBox {
    id: control

    font.family: Style.font_family

    // Main, selected text
    contentItem: Text {
        leftPadding: 12
        rightPadding: control.indicator.width + control.spacing

        text: control.displayText
        font: control.font
        color: control.pressed ? "#17a81a" : "#21be2b"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // Main background
    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        border.color: control.pressed ? "#17a81a" : "#21be2b"
        border.width: control.visualFocus ? 2 : 1
        radius: 2
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
            border.color: "#21be2b"
            radius: 2
        }
    }

    // Each dropdown item
    delegate: ItemDelegate {
        width: control.width
        contentItem: Text {
            Timer {
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    console.log("ComboBox model.ticker: ", model.ticker)
                    console.log("ComboBox change_24h: ", change_24h)
                }
            }

            text: ticker + " - " + name + " - " + change_24h
            color: "red"
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
        }

        onPaint: {
            context.reset()
            context.moveTo(0, 0)
            context.lineTo(width, 0)
            context.lineTo(width / 2, height)
            context.closePath()
            context.fillStyle = control.pressed ? "#17a81a" : "#21be2b"
            context.fill()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

