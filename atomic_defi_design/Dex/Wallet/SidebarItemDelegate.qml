import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants" as Constants
import App 1.0

GradientRectangle {
    width: list_bg.width - list_bg.border.width*2 - 6
    height: 44
    radius: Constants.Style.rectangleCornerRadius + 4

    start_color: api_wallet_page.ticker === ticker ? DexTheme.buttonColorEnabled : mouse_area.containsMouse ? DexTheme.buttonColorHovered : 'transparent'
    end_color: 'transparent'

    // Click area
    DefaultMouseArea {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if(!can_change_ticker) return

            if (mouse.button === Qt.RightButton) context_menu.popup()
            else api_wallet_page.ticker = ticker
        }
        onPressAndHold: {
            if(!can_change_ticker) return

            if (mouse.source === Qt.MouseEventNotSynthesized) context_menu.popup()
        }
    }

    // Right click menu
    CoinMenu {
        id: context_menu
    }

    readonly property double side_margin: 16

    // Icon
    DefaultImage {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: side_margin - scrollbar_margin

        source: Constants.General.coinIcon(ticker)
        width: Constants.Style.textSizeSmall4*2
        anchors.verticalCenter: parent.verticalCenter
    }

    ColumnLayout {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: icon.width + 28

        // Ticker
        DexLabel {
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: 80
            font: DexTypo.caption
            wrapMode: DexLabel.WordWrap
            text_value: mouse_area.containsMouse ? name.replace(" (TESTCOIN)", "") : ticker
            color: DexTheme.foregroundColor
        }
    }
}
