import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"
import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex
import AtomicDEX.MarketMode 1.0

Widget
{
    title: qsTr("Place Order")
    property string protocolIcon: General.platformIcon(General.coinPlatform(left_ticker))

    margins: 15
    collapsable: false

    // Market mode selector
    RowLayout
    {
        Layout.topMargin: 5
        Layout.bottomMargin: 2
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width
        height: 40

        MarketModeSelector
        {
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: (parent.width / 100) * 46
            Layout.preferredHeight: 40
            marketMode: MarketMode.Buy
            ticker: atomic_qt_utilities.retrieve_main_ticker(left_ticker)
        }

        Item { Layout.fillWidth: true }

        MarketModeSelector
        {
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: (parent.width / 100) * 46
            Layout.preferredHeight: 40
            ticker: atomic_qt_utilities.retrieve_main_ticker(left_ticker)
        }
    }

    // Protocol text for platform tokens
    Item
    {
        height: 40
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width
        visible: protocolIcon != ""

        ColumnLayout
        {
            spacing: 2
            anchors.fill: parent
            anchors.centerIn: parent

            Dex.Text
            {
                id: protocolTitle
                Layout.preferredWidth: parent.width
                text_value: "Protocol:"
                font.pixelSize: Style.textSizeSmall1
                horizontalAlignment: Text.AlignHCenter
                color: Style.colorText2
            }

            RowLayout
            {
                id: protocol
                Layout.alignment: Qt.AlignHCenter

                DefaultImage
                {
                    id: protocolImg
                    source: protocolIcon
                    Layout.preferredHeight: 16
                    Layout.preferredWidth: Layout.preferredHeight
                }

                DexLabel
                {
                    id: protocolText
                    text_value: General.getProtocolText(left_ticker)
                    wrapMode: DexLabel.NoWrap
                    font.pixelSize: Style.textSizeSmall1
                    color: Style.colorText2
                }
            }
        }
    }

    // Order selected indicator
    Item
    {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width
        height: 40

        RowLayout
        {
            id: orderSelection
            visible: API.app.trading_pg.preffered_order.price !== undefined
            anchors.fill: parent
            anchors.verticalCenter: parent.verticalCenter

            DefaultText
            {
                Layout.leftMargin: 15
                color: Dex.CurrentTheme.noColor
                text: qsTr("Order Selected")
            }

            Item { Layout.fillWidth: true }

            Qaterial.FlatButton
            {
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: 30
                Layout.rightMargin: 5
                foregroundColor: Dex.CurrentTheme.noColor
                onClicked: API.app.trading_pg.reset_order()

                Qaterial.ColorIcon
                {
                    anchors.centerIn: parent
                    iconSize: 16
                    color: Dex.CurrentTheme.noColor
                    source: Qaterial.Icons.close
                }
            }
        }

        Rectangle
        {
            visible: API.app.trading_pg.preffered_order.price !== undefined
            anchors.fill: parent
            radius: 8
            color: 'transparent'
            border.color: Dex.CurrentTheme.noColor
        }
    }

    OrderForm
    {
        id: formBase
        width: parent.width
        height: 340
        Layout.alignment: Qt.AlignHCenter
    }

    Item { Layout.fillHeight: true }

    // Error messages
    Item
    {
        height: 60
        Layout.preferredWidth: parent.width

        // Show errors
        Dex.Text
        {
            id: errors
            visible: errors.text_value !== ""
            anchors.fill: parent
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Style.textSizeSmall4
            color: Dex.CurrentTheme.noColor
            text_value: General.getTradingError(
                            last_trading_error,
                            curr_fee_info,
                            base_ticker,
                            rel_ticker, left_ticker, right_ticker)
            elide: Text.ElideRight
        }
    }

    TotalView
    {
        height: 80
        Layout.preferredWidth: parent.width
        Layout.alignment: Qt.AlignHCenter
    }

    DexGradientAppButton
    {
        height: 40
        Layout.preferredWidth: parent.width - 20
        Layout.alignment: Qt.AlignHCenter

        radius: 18
        text: qsTr("START SWAP")
        font.weight: Font.Medium
        enabled: formBase.can_submit_trade
        onClicked: confirm_trade_modal.open()
    }
}
