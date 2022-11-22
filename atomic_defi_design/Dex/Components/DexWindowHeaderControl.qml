import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.12
import ModelHelper 0.1

import Qaterial 1.0 as Qaterial

import "../Constants"
import Dex.Themes 1.0 as Dex

RowLayout
{
    property var   orders: API.app.orders_mdl.orders_proxy_mdl.ModelHelper

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

        onClicked: 
        {
            if (orders.count === 0 || !API.app.wallet_mgr.log_status()) Qt.quit()
            else app.logout_confirm_modal.open()
        }
    }
}
