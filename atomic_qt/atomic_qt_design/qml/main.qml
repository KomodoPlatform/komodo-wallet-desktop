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

    property int titlebar_wrapper_size:40

    App {
        Rectangle{
            id:titlebar
            width: parent.width
            Rectangle{
                color: Style.colorTheme8
                id:appclose
                height: titlebar_wrapper_size
                y:0
                width: titlebar_wrapper_size
                anchors.right: parent.right
                Text{
                    //text: awesome.loaded ? awesome.icons.fa_money : "x"
                    text: "×"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: 20
                }
                MouseArea{
                    width: parent.width
                    height: parent.height
                    hoverEnabled: true
                    onEntered: appclose.color="#ddd"
                    onExited: appclose.color=Style.colorTheme8
                    onClicked: Qt.quit()
                }
            }
            Rectangle{
            color: Style.colorTheme8
            id:appminimize
            height: titlebar_wrapper_size
            y:0
            width: titlebar_wrapper_size
            anchors.right: appclose.left
            Text{
                text: '-'
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 15
            }
            MouseArea{
                width: parent.width
                height: parent.height
                hoverEnabled: true
                onEntered: appminimize.color="#ddd"
                onExited: appminimize.color=Style.colorTheme8
                onClicked: showMinimized()
            }
        }
        }
        anchors.fill: parent
    }
}
