import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants" as Dex
import App 1.0

GradientRectangle
{

    width: list_bg.width - list_bg.border.width * 2 - 6
    height: 44
    radius: Dex.Style.rectangleCornerRadius + 4
    property int activation_pct: Dex.General.zhtlcActivationProgress(API.app.get_task_activation_status(ticker), ticker)
    Connections
    {
        target: API.app.settings_pg
        function onZhtlcStatusChanged() {
            activation_pct = Dex.General.zhtlcActivationProgress(API.app.get_task_activation_status(ticker), ticker)
        }
    }



    start_color: api_wallet_page.ticker === ticker ? Dex.DexTheme.buttonColorEnabled : mouse_area.containsMouse ? Dex.DexTheme.buttonColorHovered : 'transparent'
    end_color: 'transparent'

    // Click area
    DefaultMouseArea {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked:
        {
            if (mouse.button === Qt.RightButton)
            {
                context_menu.can_disable = General.canDisable(ticker)
                context_menu.popup()
            }
            else
            {
                api_wallet_page.ticker = ticker
            }
        }
        onPressAndHold: if (mouse.source === Qt.MouseEventNotSynthesized) context_menu.popup()
    }

    // Right click menu
    CoinMenu { id: context_menu }

    readonly property double side_margin: 16

    // Icon
    DefaultImage {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: side_margin - scrollbar_margin

        source: Dex.General.coinIcon(ticker)
        width: Dex.Style.textSizeSmall4*2
        anchors.verticalCenter: parent.verticalCenter


        DexRectangle
        {
            anchors.centerIn: parent
            anchors.fill: parent
            radius: 15
            enabled: activation_pct < 100
            visible: enabled
            opacity: .9
            color: Dex.DexTheme.backgroundColor
        }

        DexLabel
        {
            anchors.centerIn: parent
            anchors.fill: parent
            enabled: activation_pct < 100
            visible: enabled
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: activation_pct + "%"
            font: Dex.DexTypo.head8
            color: Dex.DexTheme.okColor
        }
    }

    ColumnLayout {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: icon.width + 28

        // Ticker
        DexLabel {
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: 80
            font: Dex.DexTypo.caption
            wrapMode: Text.WordWrap
            text_value: 
            {
                if (typeof name === 'undefined')
                {
                    if (typeof ticker === 'undefined')
                    {
                        return ""
                    }
                    else
                    {
                        return ticker
                    }
                }
                else
                {
                    return mouse_area.containsMouse ? name.replace(" (TESTCOIN)", "") : ticker
                }
            }
            color: Dex.DexTheme.foregroundColor
        }
    }
}
