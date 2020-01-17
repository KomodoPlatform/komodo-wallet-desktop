import QtQuick 2.12
import QtQuick.Window 2.12
import "Screens"
import "Constants"

Window {
    id: window
    visible: true
    width: General.width
    height: General.height
    title: qsTr("atomicDEX")
    MouseArea {
        anchors.fill: parent;
        property variant clickPos: "1,1"

        onPressed: {
            clickPos = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
            var new_x = window.x + delta.x
            var new_y = window.y + delta.y
            if (new_y <= 0)
                window.visibility = Window.Maximized
            else
            {
                if (window.visibility === Window.Maximized)
                    window.visibility = Window.Windowed
                window.x = new_x
                window.y = new_y
            }
        }
    }


    flags: Qt.FramelessWindowHint |
           Qt.WindowMinimizeButtonHint |
           Qt.Window

    App {
        anchors.fill: parent
    }
}
