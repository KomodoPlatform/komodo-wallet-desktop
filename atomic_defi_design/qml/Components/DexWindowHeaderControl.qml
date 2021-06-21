import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.12

import "../Constants"

RowLayout {
    width: 120
    anchors.right: parent.right
    height: 30
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
        Layout.preferredWidth: 40
        Layout.fillHeight: true
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
        Layout.preferredWidth: 40
        Layout.fillHeight: true
        foregroundColor: app.globalTheme.foregroundColor
        onClicked: {
            if(window.visibility==ApplicationWindow.Maximized){
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
        Layout.preferredWidth: 40
        Layout.fillHeight: true
        foregroundColor: app.globalTheme.foregroundColor
        icon.source: Qaterial.Icons.windowClose
        onClicked: Qt.quit()
    }
}
