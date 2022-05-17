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

    margins: 20
    collapsable: false

    // Market mode selector
    RowLayout
    {
        Layout.topMargin: 10
        Layout.alignment: Qt.AlignHCenter
        Layout.minimumHeight: 40
        Layout.maximumHeight: 48
        Layout.fillWidth: true
        Layout.fillHeight: true

        MarketModeSelector
        {
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: (parent.width / 100) * 46
            Layout.fillHeight: true
            marketMode: MarketMode.Buy
            ticker: atomic_qt_utilities.retrieve_main_ticker(left_ticker)
        }

        Item { Layout.fillWidth: true }

        MarketModeSelector
        {
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: (parent.width / 100) * 46
            Layout.fillHeight: true
            ticker: atomic_qt_utilities.retrieve_main_ticker(left_ticker)
        }
    }

    // Order selected indicator
    Rectangle
    {
        visible: API.app.trading_pg.preffered_order.price !== undefined
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 40
        Layout.alignment: Qt.AlignHCenter
        radius: 8
        color: 'transparent'
        border.color: Dex.CurrentTheme.noColor

        DefaultText
        {
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 15
            color: Dex.CurrentTheme.noColor
            text: qsTr("Order Selected")
        }

        Qaterial.FlatButton
        {
            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            foregroundColor: Dex.CurrentTheme.noColor
            icon.source: Qaterial.Icons.close
            backgroundImplicitWidth: 40
            backgroundImplicitHeight: 30

            onClicked: API.app.trading_pg.reset_order()
        }
    }

    OrderForm
    {
        id: form_base
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
        enabled: form_base.can_submit_trade
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
