// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtCharts 2.3
import QtWebEngine 1.8
import QtGraphicalEffects 1.0

import Qaterial 1.0 as Qaterial

// Project Imports
import "../Components"
import "../Constants"
import App 1.0
import "../Exchange/Trade"
import Dex.Themes 1.0 as Dex

// Right side, main
Item
{
    id: root
    property alias send_modal: send_modal
    readonly property int layout_margin: 30
    function loadingPercentage(remaining) {
        return General.formatPercent((100 * (1 - parseFloat(remaining)/parseFloat(current_ticker_infos.current_block))).toFixed(3), false)
    }

    readonly property var transactions_mdl: api_wallet_page.transactions_mdl

    Layout.fillHeight: true
    Layout.fillWidth: true

    ColumnLayout
    {
        id: wallet_layout

        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: layout_margin
        anchors.bottom: parent.bottom

        spacing: 30

        // Balance box
        InnerBackground
        {
            id: balance_box

            Layout.fillWidth: true
            Layout.preferredHeight: 95
            Layout.leftMargin: layout_margin
            Layout.rightMargin: layout_margin

            RowLayout
            {
                anchors.fill: parent

                RowLayout
                {
                    Layout.alignment: Qt.AlignLeft
                    Layout.topMargin: 12
                    Layout.bottomMargin: Layout.topMargin
                    Layout.leftMargin: 15
                    spacing: 15

                    // Icon
                    DefaultImage
                    {
                        source: General.coinIcon(api_wallet_page.ticker)
                        Layout.preferredHeight: 60
                        Layout.preferredWidth: Layout.preferredHeight
                    }

                    // Name and crypto amount
                    ColumnLayout
                    {
                        id: balance_layout
                        spacing: 3

                        DexLabel
                        {
                            id: name
                            text_value: current_ticker_infos.name
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: Style.textSizeMid
                        }

                        DexLabel
                        {
                            id: name_value
                            text_value: General.formatCrypto("", current_ticker_infos.balance, api_wallet_page.ticker)
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: name.font.pixelSize
                            privacy: true
                        }
                    }
                }

                ColumnLayout {
                    visible: false //current_ticker_infos.segwit_supported
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 3
                    DexLabel {
                       text_value: qsTr("Segwit")
                       Layout.alignment: Qt.AlignLeft
                       font.pixelSize: name.font.pixelSize
                    }
                    DefaultSwitch {
                        id: segwitSwitch
                        Layout.alignment: Qt.AlignVCenter
                        onToggled: {
                            if(parseFloat(current_ticker_infos.balance) > 0) {
                                 Qaterial.DialogManager.showDialog({
                                    title: qsTr("Confirmation"),
                                    text:  qsTr("Do you want to send your %1 funds to %2 wallet first?").arg(current_ticker_infos.is_segwit_on ? "segwit" : "legacy").arg(!current_ticker_infos.is_segwit_on ? "segwit" : "legacy"),
                                    standardButtons: Dialog.Yes | Dialog.No,
                                    onAccepted: function() {
                                        var address = API.app.wallet_pg.switch_address_mode(!current_ticker_infos.is_segwit_on);
                                        if (address != current_ticker_infos.address && address != "") {
                                            send_modal.open()
                                            send_modal.item.address_field.text = address
                                            send_modal.item.max_mount.checked = true
                                            send_modal.item.segwit = true
                                            send_modal.item.segwit_callback = function () {
                                                if(send_modal.item.segwit_success) {
                                                    API.app.wallet_pg.post_switch_address_mode(!current_ticker_infos.is_segwit_on)
                                                    Qaterial.DialogManager.showDialog({
                                                        title: qsTr("Success"),
                                                        text: qsTr("Your transaction is send, may take some time to arrive")
                                                    })
                                                } else {
                                                    segwitSwitch.checked = current_ticker_infos.is_segwit_on
                                                }
                                            }
                                        }
                                    },
                                    onRejected: function () {
                                        app.segwit_on = true
                                        API.app.wallet_pg.post_switch_address_mode(!current_ticker_infos.is_segwit_on)
                                    }
                                })

                            } else {
                                app.segwit_on = true
                                API.app.wallet_pg.post_switch_address_mode(!current_ticker_infos.is_segwit_on)
                            }

                        }
                    }
                }

                Connections
                {
                    target: API.app.wallet_pg
                    function onTickerInfosChanged()
                    {
                        if (segwitSwitch.checked != current_ticker_infos.is_segwit_on)
                        {
                            segwitSwitch.checked = current_ticker_infos.is_segwit_on
                        }
                    }
                }

                // Wallet Balance
                ColumnLayout
                {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: balance_layout.spacing
                    DexLabel
                    {
                        text_value: qsTr("Wallet Balance")
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: name.font.pixelSize
                        color: price.color
                    }

                    DexLabel
                    {
                        text_value: General.formatFiat("", current_ticker_infos.fiat_amount, API.app.settings_pg.current_currency)
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: name.font.pixelSize
                        privacy: true
                    }
                }

                VerticalLine
                {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.rightMargin: 30
                    height: balance_layout.height * 0.8
                    color: Style.colorThemeDarkLight
                }

                // Price
                ColumnLayout
                {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: balance_layout.spacing
                    DexLabel
                    {
                        id: price
                        text_value: qsTr("Price")
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: name.font.pixelSize
                        color: Style.colorText2
                    }

                    DexLabel
                    {
                        text_value: General.formatFiat('', current_ticker_infos.current_currency_ticker_price, API.app.settings_pg.current_currency)
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: name.font.pixelSize
                    }
                }

                // Change 24h
                ColumnLayout
                {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: balance_layout.spacing
                    DexLabel
                    {
                        text_value: qsTr("Change 24h")
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: name.font.pixelSize
                        color: price.color
                    }

                    DexLabel
                    {
                        text_value:
                        {
                            const v = parseFloat(current_ticker_infos.change_24h)
                            return v === 0 ? '-' : General.formatPercent(v)
                        }
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: name.font.pixelSize
                        color: DexTheme.getValueColor(current_ticker_infos.change_24h)
                    }
                }

                // Portfolio %
                ColumnLayout
                {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: balance_layout.spacing
                    DexLabel
                    {
                        text_value: qsTr("Portfolio %")
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: name.font.pixelSize
                        color: price.color
                    }

                    DexLabel
                    {
                        text_value:
                        {
                            const fiat_amount = parseFloat(current_ticker_infos.fiat_amount)
                            const portfolio_balance = parseFloat(API.app.portfolio_pg.balance_fiat_all)
                            if(fiat_amount <= 0 || portfolio_balance <= 0) return "-"

                            return General.formatPercent((100 * fiat_amount/portfolio_balance).toFixed(2), false)
                        }
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: name.font.pixelSize
                        privacy: true
                    }
                }
            }
        }

        // Address Book, Send, Receive buttons
        RowLayout
        {
            Layout.leftMargin: layout_margin
            Layout.rightMargin: layout_margin
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 25
            Item
            {
                Layout.preferredWidth: 199
                Layout.preferredHeight: 48
                DexAppButton
                {
                    enabled: API.app.wallet_pg.send_available

                    anchors.fill: parent
                    radius: 18

                    label.text: qsTr("Send")
                    label.font.pixelSize: 16
                    content.anchors.left: content.parent.left
                    content.anchors.leftMargin: enabled ? 23 : 60

                    onClicked:
                    {
                        if (API.app.wallet_pg.current_ticker_fees_coin_enabled) send_modal.open()
                        else enable_fees_coin_modal.open()
                    }

                    Arrow
                    {
                        id: arrow_send
                        up: true
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 19
                    }
                }

                DefaultImage
                {
                    visible: API.app.wallet_pg.send_availability_state !== ""

                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qaterial.Icons.alert

                    DefaultColorOverlay
                    {
                        anchors.fill: parent
                        source: parent
                        color: "yellow"
                    }
                    MouseArea
                    {
                        id: send_alert_mouse_area
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    DefaultTooltip
                    {
                        visible: send_alert_mouse_area.containsMouse
                        text: API.app.wallet_pg.send_availability_state
                    }
                }
            }

            ModalLoader
            {
                id: send_modal
                sourceComponent: SendModal {}
            }

            Component
            {
                id: enable_fees_coin_comp
                BasicModal
                {
                    id: root
                    width: 300
                    ModalContent
                    {
                        title: qsTr("Enable %1 ?").arg(coin_to_enable_ticker)
                        RowLayout
                        {
                            Layout.fillWidth: true
                            DefaultButton
                            {
                                Layout.fillWidth: true
                                text: qsTr("Yes")
                                onClicked:
                                {
                                    if (API.app.enable_coin(coin_to_enable_ticker) === false)
                                    {
                                        enable_fees_coin_failed_modal.open()
                                    }
                                    close()
                                }
                            }
                            DefaultButton {
                                Layout.fillWidth: true
                                text: qsTr("No")
                                onClicked: close()
                            }
                        }
                    }
                }
            }

            ModalLoader
            {
                property string coin_to_enable_ticker: API.app.wallet_pg.ticker_infos.fee_ticker
                id: enable_fees_coin_modal
                sourceComponent: enable_fees_coin_comp
            }

            ModalLoader
            {
                id: enable_fees_coin_failed_modal
                sourceComponent: CannotEnableCoinModal { coin_to_enable_ticker: API.app.wallet_pg.ticker_infos.fee_ticker }
            }

            DexAppButton
            {
                Layout.preferredWidth: 199
                Layout.preferredHeight: 48
                radius: 18

                label.text: qsTr("Receive")
                label.font.pixelSize: 16
                content.anchors.left: content.parent.left
                content.anchors.leftMargin: 23

                onClicked: receive_modal.open()

                Arrow
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: arrow_send.anchors.rightMargin
                    up: false
                }
            }

            ModalLoader
            {
                id: receive_modal
                sourceComponent: ReceiveModal {}
            }

            DexAppButton
            {
                visible: !is_dex_banned

                Layout.preferredWidth: 199
                Layout.preferredHeight: 48
                radius: 18

                // Inner text.
                label.text: qsTr("Swap")
                label.font.pixelSize: 16
                content.anchors.left: content.parent.left
                content.anchors.leftMargin: 23

                onClicked: onClickedSwap()

                Row
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: arrow_send.anchors.rightMargin
                    spacing: 3
                    
                    Arrow
                    {
                        up: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Arrow
                    {
                        up: false
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Item { Layout.fillWidth: true }

            DexAppButton
            {
                text: qsTr("Rewards")
                Layout.preferredWidth: 150
                Layout.preferredHeight: 48
                radius: 18
                font.pixelSize: 16
                visible: current_ticker_infos.is_claimable && !API.app.is_pin_cfg_enabled()
                enabled: parseFloat(current_ticker_infos.balance) > 0
                onClicked:
                {
                    claimRewardsModal.open()
                    claimRewardsModal.item.prepareClaimRewards()
                }
            }

            ModalLoader
            {
                id: claimRewardsModal
                sourceComponent: ClaimRewardsModal {}
            }

            DexAppButton
            {
                text: qsTr("Faucet")
                Layout.preferredWidth: 150
                Layout.preferredHeight: 48
                radius: 18
                font.pixelSize: 16
                visible: enabled && current_ticker_infos.is_smartchain_test_coin

                onClicked: api_wallet_page.claim_faucet()
            }

            Component.onCompleted: api_wallet_page.claimingFaucetRpcDataChanged.connect(onClaimFaucetRpcResultChanged)
            Component.onDestruction: api_wallet_page.claimingFaucetRpcDataChanged.disconnect(onClaimFaucetRpcResultChanged)
            function onClaimFaucetRpcResultChanged() { claimFaucetResultModal.open() }

            ModalLoader {
                id: claimFaucetResultModal
                sourceComponent: ClaimFaucetResultModal {}
            }
        }

        // Price Graph
        InnerBackground
        {
            visible: false
            id: price_graph_bg

            property bool ticker_supported: false
            readonly property bool is_fetching: webEngineView.loadProgress < 100
            property var ticker: api_wallet_page.ticker

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: layout_margin
            Layout.rightMargin: layout_margin
            Layout.bottomMargin: -parent.spacing * 0.5
            Layout.preferredHeight: wallet.height * 0.6

            radius: 18

            onTickerChanged: loadChart()

            function loadChart()
            {
                const pair = atomic_qt_utilities.retrieve_main_ticker(ticker) + "/" + atomic_qt_utilities.retrieve_main_ticker(API.app.settings_pg.current_currency)
                const pair_reversed = atomic_qt_utilities.retrieve_main_ticker(API.app.settings_pg.current_currency) + "/" + atomic_qt_utilities.retrieve_main_ticker(ticker)
                const pair_usd = atomic_qt_utilities.retrieve_main_ticker(ticker) + "/" + "USD"
                const pair_usd_reversed = "USD" + "/" + atomic_qt_utilities.retrieve_main_ticker(ticker)
                const pair_busd = atomic_qt_utilities.retrieve_main_ticker(ticker) + "/" + "BUSD"
                const pair_busd_reversed = "BUSD" + "/" + atomic_qt_utilities.retrieve_main_ticker(ticker)

                // Normal pair
                let symbol = General.supported_pairs[pair]
                if (!symbol) {
                    console.warn("Symbol not found for", pair)
                    symbol = General.supported_pairs[pair_reversed]
                }

                // Reversed pair
                if (!symbol) {
                    console.warn("Symbol not found for", pair_reversed)
                    symbol = General.supported_pairs[pair_usd]
                }

                // Pair with USD
                if (!symbol) {
                    console.warn("Symbol not found for", pair_usd)
                    symbol = General.supported_pairs[pair_usd_reversed]
                }

                // Reversed pair with USD
                if (!symbol) {
                    console.warn("Symbol not found for", pair_usd_reversed)
                    symbol = General.supported_pairs[pair_busd]
                }

                // Pair with BUSD
                if (!symbol) {
                    console.warn("Symbol not found for", pair_busd)
                    symbol = General.supported_pairs[pair_busd_reversed]
                }

                // Reversed pair with BUSD
                if (!symbol) {
                    console.warn("Symbol not found for", pair_busd_reversed)
                    console.warn("No chart for", ticker)
                    ticker_supported = false
                    return
                }

                ticker_supported = true

                console.debug("Wallet: Loading chart for %1".arg(symbol))

//                webEngineView.loadHtml(`<style>
//                                        body { margin: 0; background: %1 }
//                                        </style>
//                                        <!-- TradingView Widget BEGIN -->
//                                        <div class="tradingview-widget-container">
//                                          <div class="tradingview-widget-container__widget"></div>
//                                          <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-mini-symbol-overview.js" async>
//                                          {
//                                              "symbol": "${symbol}",
//                                              "width": "100%",
//                                              "height": "100%",
//                                              "locale": "en",
//                                              "dateRange": "1D",
//                                              "colorTheme": "dark",
//                                              "trendLineColor": "%2",
//                                              "isTransparent": true,
//                                              "autosize": false,
//                                              "largeChartUrl": ""
//                                          }
//                                          </script>
//                                        </div>
//                                        <!-- TradingView Widget END -->`.arg(Dex.CurrentTheme.floatingBackgroundColor).arg(Dex.CurrentTheme.textSelectionColor))
            }

            WebEngineView
            {
                id: webEngineView
                anchors.fill: parent
                visible: parent.ticker_supported && !loading
            }

            Connections
            {
                target: Dex.CurrentTheme
                function onThemeChanged()
                {
                    loadChart();
                }
            }

            RowLayout
            {
                visible: !webEngineView.visible && parent.ticker_supported
                anchors.centerIn: parent

                DefaultBusyIndicator
                {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: -15
                    Layout.rightMargin: Layout.leftMargin*0.75
                    scale: 0.5
                }

                DexLabel
                {
                    text_value: qsTr("Loading market data") + "..."
                }
            }

            DexLabel
            {
                visible: !parent.ticker_supported
                text_value: qsTr("There is no chart data for this ticker yet")
                anchors.centerIn: parent
            }
        }

        // Transactions or loading
        Item {
            id: loading_tx
            visible: current_ticker_infos.tx_state === "InProgress"
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            implicitHeight: 100

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                DexLabel {
                    text_value: qsTr("Loading")
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Style.textSize2
                }

                DefaultBusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                }

                DexLabel {
                    text_value: General.isTokenType(current_ticker_infos.type) ?
                                (qsTr("Scanning blocks for TX History...") + " " + loadingPercentage(current_ticker_infos.blocks_left)) :
                                (qsTr("Syncing TX History...") + " " + loadingPercentage(current_ticker_infos.transactions_left))

                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Separator line
        HorizontalLine {
            visible: loading_tx.visible && transactions_mdl.length > 0
            width: 720
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            id: transactions_bg
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: layout_margin
            Layout.rightMargin: layout_margin
            Layout.bottomMargin: !fetching_text_row.visible ? layout_margin : undefined

            implicitHeight: wallet.height*0.54

            color: Dex.CurrentTheme.floatingBackgroundColor
            radius: 22

            ClipRRect {
                radius: parent.radius
                width: transactions_bg.width
                height: transactions_bg.height

                DexRectangle
                {
                    anchors.fill: parent
                    gradient: Gradient
                    {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.001; color: Dex.CurrentTheme.innerBackgroundColor }
                        GradientStop { position: 1; color: Dex.CurrentTheme.backgroundColor }
                    }
                }

                DefaultText {
                    anchors.centerIn: parent
                    visible: current_ticker_infos.tx_state !== "InProgress" && transactions_mdl.length === 0
                    text_value: api_wallet_page.tx_fetching_busy ? (qsTr("Refreshing") + "...") : qsTr("No transactions")
                    font.pixelSize: Style.textSize
                }

                Transactions {
                    width: parent.width
                    height: parent.height
                    model: transactions_mdl.proxy_mdl
                }
            }
        }

        RowLayout {
            id: fetching_text_row
            visible: api_wallet_page.tx_fetching_busy
            Layout.preferredHeight: fetching_text.font.pixelSize * 1.5

            Layout.topMargin: -layout_margin*0.5
            Layout.bottomMargin: layout_margin*0.5

            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            DefaultBusyIndicator {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: Style.textSizeSmall3
                Layout.preferredHeight: Layout.preferredWidth
            }

            DefaultText {
                id: fetching_text
                Layout.alignment: Qt.AlignVCenter
                text_value: qsTr("Fetching transactions") + "..."
                font.pixelSize: Style.textSizeSmall3
            }
        }

        implicitHeight: Math.min(contentItem.childrenRect.height, wallet.height*0.5)
    }
}
