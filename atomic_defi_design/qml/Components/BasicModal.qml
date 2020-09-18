import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    padding: 10

    width: 900
    height: column_layout.height + verticalPadding * 2

    property alias currentIndex: stack_layout.currentIndex
    property alias count: stack_layout.count
    default property alias pages: stack_layout.data

    function nextPage() {
        if(currentIndex === count - 1) root.close()
        else currentIndex += 1
    }

    function previousPage() {
        if(currentIndex === 0) root.close()
        else currentIndex -= 1
    }

    Column {
        id: column_layout
        spacing: Style.rowSpacing
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter

        Row {
            id: page_indicator
            visible: root.count > 1
            anchors.horizontalCenter: parent.horizontalCenter

            layoutDirection: Qt.RightToLeft

            Repeater {
                model: root.count
                delegate: Item {
                    width: (index === root.count-1 ? 0 : circle.width*2) + circle.width*0.5
                    height: circle.height * 1.5
                    AnimatedRectangle {
                        id: rectangle
                        height: circle.height/4
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: -circle.width*0.5
                        anchors.right: circle.horizontalCenter
                        color: circle.color
                    }

                    Circle {
                        id: circle
                        width: 24
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.currentIndex >= (root.count-1 - index) ? Style.colorGreen : Style.colorTheme5
                    }
                }
            }
        }

        // Inside modal
        StackLayout {
            id: stack_layout
            width: parent.width
            height: stack_layout.children[stack_layout.currentIndex].height
        }
    }
}
