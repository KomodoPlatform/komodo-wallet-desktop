import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"
import Dex.Themes 1.0 as Dex
import AtomicDEX.MarketMode 1.0

Widget
{
    title: qsTr("Place Order")
    property string protocolIcon: General.platformIcon(General.coinPlatform(left_ticker))

    margins: 15
    collapsable: false


    // Order selected indicator
    Item
    {
        Layout.topMargin: 5
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 40
        visible: API.app.trading_pg.preffered_order.price !== undefined

        RowLayout
        {
            id: orderSelection
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
            anchors.fill: parent
            radius: 8
            color: 'transparent'
            border.color: Dex.CurrentTheme.noColor
        }
    }

    // Market mode selector
    RowLayout
    {
        Layout.topMargin: 5
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width
        Layout.fillHeight: true

        MarketModeSelector
        {
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: (parent.width / 100) * 46
            Layout.preferredHeight: 50
            marketMode: MarketMode.Buy
            ticker: atomic_qt_utilities.retrieve_main_ticker(left_ticker)
        }

        Item { Layout.fillWidth: true }

        MarketModeSelector
        {
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: (parent.width / 100) * 46
            Layout.preferredHeight: 50
            ticker: atomic_qt_utilities.retrieve_main_ticker(left_ticker)
        }
    }

    HorizontalLine
    {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width
        visible: protocolIcon != ""
        color: Dex.CurrentTheme.backgroundColorDeep
    }

    ColumnLayout
    {
        spacing: 3
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: parent.width
        visible: protocolIcon != ""

        DexLabel
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
            Layout.preferredWidth: parent.width

            Item { Layout.fillWidth: true }

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

            Item { Layout.fillWidth: true }
        }
    }

    OrderForm
    {
        id: formBase
        Layout.preferredWidth: parent.width
        Layout.alignment: Qt.AlignHCenter
    }

    TotalView
    {
        Layout.preferredWidth: parent.width
        Layout.alignment: Qt.AlignHCenter
    }

    DexGradientAppButton
    {
        Layout.preferredHeight: 40
        Layout.preferredWidth: parent.width - 20
        Layout.alignment: Qt.AlignHCenter

        radius: 18
        text: qsTr("START SWAP")
        font.weight: Font.Medium
        enabled: formBase.can_submit_trade
        onClicked: confirm_trade_modal.open()
    }

    ColumnLayout
    {
        spacing: parent.spacing
        visible: errors.text_value !== ""
        Layout.preferredWidth: parent.width

        HorizontalLine
        {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width
        }

        // Show errors
        DefaultText
        {
            id: errors
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width
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
}
