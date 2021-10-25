import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.12

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex

RowLayout
{
    width: 120
    anchors.right: parent.right
    height: 30
    spacing: 0
    anchors.top: parent.top
    anchors.topMargin: 0

    Qaterial.FlatButton
    {
        topInset: 0
        leftInset: 0
        rightInset: 0
        bottomInset: 0
        radius: 0
        opacity: .7
        Layout.preferredWidth: 40
        Layout.fillHeight: true
        foregroundColor: Dex.CurrentTheme.foregroundColor
        icon.source: Qaterial.Icons.windowMinimize
        onClicked: window.showMinimized()
    }

    Qaterial.FlatButton
    {
        topInset: 0
        leftInset: 0
        rightInset: 0
        bottomInset: 0
        radius: 0
        opacity: .7
        Layout.preferredWidth: 40
        Layout.fillHeight: true
        foregroundColor: Dex.CurrentTheme.foregroundColor
        icon.source: window.visibility === ApplicationWindow.Maximized ? Qaterial.Icons.dockWindow : Qaterial.Icons.windowMaximize

        onClicked:
        {
            if (window.visibility == ApplicationWindow.Maximized) {
                showNormal()
            } else {
                showMaximized()
            }
        }
    }

    Qaterial.FlatButton
    {
        topInset: 0
        leftInset: 0
        rightInset: 0
        bottomInset: 0
        radius: 0
        opacity: .7
        accentRipple: Qaterial.Colors.red
        Layout.preferredWidth: 40
        Layout.fillHeight: true
        foregroundColor: Dex.CurrentTheme.foregroundColor
        icon.source: Qaterial.Icons.windowClose

        onClicked: Qt.quit()
    }
}
