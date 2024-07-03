import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"
import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex
import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0

ColumnLayout
{
    Layout.preferredWidth: 305
    Layout.fillHeight: true
    property alias currentIndex: orderformTabView.currentIndex
    property int loop_count: 0
    property bool show_waiting_for_trade_preimage: false;
    property var fees: API.app.trading_pg.fees
    property var preimage_rpc_busy: API.app.trading_pg.preimage_rpc_busy
    property var trade_preimage_error: fees.hasOwnProperty('error') ? fees["error"].split("] ").slice(-1) : ""
    readonly property bool trade_preimage_ready: fees.hasOwnProperty('base_transaction_fees_ticker')
    property int takerOrderform_idx: 0
    property int makerOrderform_idx: 1

    function reset_fees_state()
    {
        show_waiting_for_trade_preimage = false;
        check_trade_preimage.stop()
        loop_count = 0
        API.app.trading_pg.reset_fees()
        takerForm.dexErrors.text_value = ""
        makerForm.dexErrors.text_value = ""
    }

    Connections {
        target: API.app.trading_pg

        function onFeesChanged() {
            // console.log("onFeesChanged::fees: " + JSON.stringify(fees))
        }

        function onPreImageRpcStatusChanged(){
            // console.log("onPreImageRpcStatusChanged::preimage_rpc_busy: " + API.app.trading_pg.preimage_rpc_busy)
        }
        function onPreferredOrderChanged(){
            reset_fees_state()
        }
    }

    Connections
    {
        target: app
        function onPairChanged(left, right)
        {
            reset_fees_state()
        }
    }

    Connections
    {
        target: exchange_trade
        function onOrderSelected()
        {
            reset_fees_state()
        }
    }

    Timer
    {
        id: check_trade_preimage
        interval: 500;
        running: false;
        repeat: true;
        triggeredOnStart: true;
        onTriggered: {
            loop_count++;
            console.log("Getting fees info... " + loop_count + "/50")
            if (trade_preimage_ready)
            {
                show_waiting_for_trade_preimage = false
                loop_count = 0
                stop()
                confirm_trade_modal.open()
            }
            else if (trade_preimage_error != "")
            {
                loop_count = 0
                takerForm.dexErrors.text_value = trade_preimage_error.toString()
                makerForm.dexErrors.text_value = trade_preimage_error.toString()
                show_waiting_for_trade_preimage = false
                stop()
            }
            else if (loop_count > 50)
            {
                loop_count = 0
                show_waiting_for_trade_preimage = false
                trade_preimage_error = "Trade preimage timed out, try again."
                stop()
            }
        }
    }

    Qaterial.LatoTabBar
    {
        id: orderformTabView

        background: null
        Layout.leftMargin: 6

        Qaterial.LatoTabButton
        {
            text: qsTr("Taker Order")
            font.pixelSize: 14
            textColor: checked ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
            textSecondaryColor: Dex.CurrentTheme.foregroundColor2
            indicatorColor: Dex.CurrentTheme.foregroundColor
        }
        Qaterial.LatoTabButton
        {
            text: qsTr("Maker Order")
            font.pixelSize: 14
            textColor: checked ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
            textSecondaryColor: Dex.CurrentTheme.foregroundColor2
            indicatorColor: Dex.CurrentTheme.foregroundColor
        }
    }

    Rectangle
    {
        Layout.fillHeight: true
        color: Dex.CurrentTheme.floatingBackgroundColor
        radius: 10
        Layout.preferredWidth: 305

        Qaterial.SwipeView
        {
            id: orderformSwipeView
            clip: true
            interactive: false
            currentIndex: orderformTabView.currentIndex
            anchors.fill: parent

            onCurrentIndexChanged:
            {
                API.app.trading_pg.maker_mode = currentIndex === makerOrderform_idx ? true : false
                orderformSwipeView.currentItem.update()
                API.app.trading_pg.reset_order()
                reset_fees_state()
            }

            Item
            {
                id: takerOrderform

                OrderForm
                {
                    id: takerForm
                    width: parent.width
                    height: 330
                    Layout.alignment: Qt.AlignHCenter
                    swap_btn.enabled: last_trading_error === TradingError.None && !show_waiting_for_trade_preimage && takerForm.dexErrors.text_value == ""
                    swap_btn.onClicked: 
                    {
                        console.log("Getting fees info...")
                        API.app.trading_pg.determine_fees()
                        show_waiting_for_trade_preimage = true
                        check_trade_preimage.start()
                    }
                    swap_btn_spinner.visible: show_waiting_for_trade_preimage
                }
            }

            Item
            {
                id: makerOrderform

                OrderForm
                {
                    id: makerForm
                    width: parent.width
                    height: 330
                    Layout.alignment: Qt.AlignHCenter
                    swap_btn.enabled: last_trading_error === TradingError.None && !show_waiting_for_trade_preimage && makerForm.dexErrors.text_value == ""
                    swap_btn.onClicked: 
                    {
                        console.log("Getting fees info...")
                        console.log("API.app.trading_pg.market_mode")
                        console.log(API.app.trading_pg.market_mode)
                        // TODO: Apply reduced fees on maker orders
                        API.app.trading_pg.determine_fees()
                        show_waiting_for_trade_preimage = true;
                        check_trade_preimage.start()
                    }
                    swap_btn_spinner.visible: show_waiting_for_trade_preimage
                }
            }
        }
    }
}