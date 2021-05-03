import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.12

Item {
    anchors.fill: parent
    Item {
        width: parent.width
        y: 1
        height: 40
        Rectangle {
            anchors.fill: parent
            visible: false
            color: app.globalTheme.surfaceColor
        }
        MouseArea {
            onPressed: window.startSystemMove();
            anchors.fill: parent
        }
        RowLayout {
            width: 195
            anchors.right: parent.right
            height: 40
            spacing: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            Qaterial.FlatButton {
                topInset: 0
                leftInset: 0
                rightInset: 0
                bottomInset: 0
                radius: 0
                opacity: .7
                foregroundColor: app.globalTheme.foregroundColor
                icon.source: Qaterial.Icons.windowMinimize
                onClicked: window.showMinimized()

            }
            Qaterial.FlatButton {
                topInset: 0
                leftInset: 0
                rightInset: 0
                bottomInset: 0
                radius: 0
                opacity: .7
                foregroundColor: app.globalTheme.foregroundColor
                onClicked: {
                    if(window.visibility===ApplicationWindow.Maximized){
                        showNormal()
                    }else {
                        showMaximized()
                    }
                }

                icon.source: window.visibility===ApplicationWindow.Maximized? Qaterial.Icons.dockWindow : Qaterial.Icons.windowMaximize
            }
            Qaterial.FlatButton {
                topInset: 0
                leftInset: 0
                rightInset: 0
                bottomInset: 0
                radius: 0
                opacity: .7
                accentRipple: Qaterial.Colors.red
                foregroundColor: app.globalTheme.foregroundColor
                icon.source: Qaterial.Icons.windowClose
                onClicked: Qt.quit()
            }
        }
    }
    Item {
        id: _left_resize
        height: parent.height
        width: 3
        MouseArea {
            onPressed: window.startSystemResize(Qt.LeftEdge)
            anchors.fill: parent
            cursorShape: "SizeHorCursor"
        }
    }
    Item {
        id: _right_resize
        height: parent.height
        anchors.right: parent.right
        width: 3
        MouseArea {
            onPressed: {
                window.startSystemResize(Qt.RightEdge)
            }
            cursorShape: "SizeHorCursor"
        }
    }
    Item {
        id: _bottom_resize
        height: 3
        width: parent.width
        anchors.bottom: parent.bottom
        MouseArea {
            onPressed: if (active) window.startSystemResize(Qt.BottomEdge)
            //target: null
            anchors.fill: parent
            cursorShape: "SizeVerCursor"
        }
    }
    Item {
        id: _top_resize
        height: 3
        width: parent.width
        MouseArea {
            onPressed: window.startSystemResize(Qt.TopEdge)
            //target: null
            anchors.fill: parent
            cursorShape: "SizeVerCursor"
        }
    }
    Item {
        id: _bottom_right_resize
        height: 6
        width: 6
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        MouseArea {
            onPressed: if (active) window.startSystemResize(Qt.BottomEdge | Qt.RightEdge)
            anchors.fill: parent
            cursorShape: "SizeFDiagCursor"
        }
    }
}
