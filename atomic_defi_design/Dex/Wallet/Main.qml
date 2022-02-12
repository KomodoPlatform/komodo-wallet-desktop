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
    readonly property int layout_margin: 20
    readonly property string headerTitleColor: Style.colorText2
    readonly property string headerTitleFont: Style.textSizeMid
    readonly property string headerTextColor: Dex.CurrentTheme.foregroundColor
    readonly property string headerTextFont: Style.textSizeSmall5
    readonly property string headerSmallFont: Style.textSizeSmall2

    function loadingPercentage(remaining) {
        return General.formatPercent((100 * (1 - parseFloat(remaining)/parseFloat(current_ticker_infos.current_block))).toFixed(3), false)
    }

    readonly property var transactions_mdl: api_wallet_page.transactions_mdl

    Layout.fillHeight: true
    Layout.fillWidth: true

    ColumnLayout
    {
        id: wallet_layout
        spacing: 20
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: layout_margin
        anchors.bottom: parent.bottom

        // Balance box
        InnerBackground
        {
            id: balance_box
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            Layout.leftMargin: layout_margin
            Layout.rightMargin: layout_margin

            RowLayout
            {
                anchors.fill: parent

                RowLayout
                {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: Layout.topMargin
                    Layout.leftMargin: 10
                    spacing: 10

                    // Icon
                    DefaultImage
                    {
                        id: icon_img
                        Layout.preferredHeight: 80
                        Layout.preferredWidth: Layout.preferredHeight
                        source: General.coinIcon(api_wallet_page.ticker)
                    }

                    Item { Layout.fillWidth: true }

                    // Name and crypto amount
                    ColumnLayout
                    {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        spacing: 2

                        DexLabel
                        {
                            id: name
                            Layout.alignment: Qt.AlignHCenter
                            text_value: General.fullCoinName(current_ticker_infos.name, api_wallet_page.ticker)
                            font.pixelSize: headerTitleFont
                            color: headerTextColor
                        }

                        DexLabel
                        {
                            Layout.alignment: Qt.AlignHCenter
                            text_value:
                            {
                                const fiat_amount = parseFloat(current_ticker_infos.fiat_amount)
                                const portfolio_balance = parseFloat(API.app.portfolio_pg.balance_fiat_all)
                                if(fiat_amount <= 0 || portfolio_balance <= 0) return "-"

                                return General.formatPercent((100 * fiat_amount/portfolio_balance).toFixed(2), false)
                                + " of Portfolio"
                            }
                            visible: text_value !== '-'
                            font.pixelSize: headerTextFont
                            color: headerTextColor
                            privacy: true
                        }

                        RowLayout
                        {
                            Layout.topMargin: 0
                            Layout.bottomMargin: 0
                            Layout.alignment: Qt.AlignHCenter

                            DexLabel
                            {
                                id: wallet_address
                                text_value: qsTr("Address: ") + api_wallet_page.ticker_infos.address
                                font.pixelSize: headerSmallFont
                                color: headerTitleColor
                            }

                            Qaterial.Icon {
                                x: wallet_address.implicitWidth + 10
                                size: headerSmallFont
                                icon: Qaterial.Icons.contentCopy
                                color: address_copyArea.containsMouse ? headerTextColor : headerTitleColor

                                DexMouseArea {
                                    id: address_copyArea
                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onClicked:
                                    {
                                        API.qt_utilities.copy_text_to_clipboard(api_wallet_page.ticker_infos.address)
                                        app.notifyCopy(qsTr("Address"), qsTr("copied to clipboard"))

                                    }
                                }
                            }
                        }

                        RowLayout
                        {
                            Layout.topMargin: 0
                            Layout.bottomMargin: 0
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredHeight: coinContractAddress(api_wallet_page.ticker) ? headerSmallFont : 0
                            visible: General.coinContractAddress(api_wallet_page.ticker) !== ""

                            DexLabel
                            {
                                id: contract_address
                                text_value:  api_wallet_page.ticker_infos.type + qsTr(" Contract: ") + General.coinContractAddress(api_wallet_page.ticker)
                                font.pixelSize: headerSmallFont
                                color: headerTitleColor
                            }

                            Qaterial.Icon {
                                x: contract_address.implicitWidth + 10
                                size: headerSmallFont
                                icon: Qaterial.Icons.contentCopy
                                color: contract_copyArea.containsMouse ? headerTextColor : headerTitleColor
                                visible: General.coinContractAddress(api_wallet_page.ticker) !== ""

                                DexMouseArea {
                                    id: contract_copyArea
                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onClicked: {
                                        API.qt_utilities.copy_text_to_clipboard(General.coinContractAddress(api_wallet_page.ticker), "")
                                        app.notifyCopy(qsTr("Contract address"), qsTr("copied to clipboard"))
                                    }
                                }
                            }
                        }
                    }
                    Item { Layout.fillWidth: true }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        spacing: 2
                        visible: false //current_ticker_infos.segwit_supported

                        DexLabel {
                           Layout.alignment: Qt.AlignLeft
                           text_value: qsTr("Segwit")
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

                    // Price
                    ColumnLayout
                    {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        spacing: 5

                        DexLabel
                        {
                            id: price
                            Layout.alignment: Qt.AlignHCenter
                            text_value: qsTr("Price")
                            font.pixelSize: name.font.pixelSize
                            color: headerTitleColor
                        }

                        DexLabel
                        {
                            Layout.alignment: Qt.AlignHCenter
                            text_value:
                            {
                                const v = General.formatFiat('', current_ticker_infos.current_currency_ticker_price, API.app.settings_pg.current_currency)
                                return current_ticker_infos.current_currency_ticker_price == 0 ? 'N/A' : v
                            }
                            font.pixelSize: headerTextFont
                            color: headerTextColor
                        }
                        DexLabel
                        {
                            Layout.alignment: Qt.AlignHCenter
                            text_value:
                            {
                                const v = parseFloat(current_ticker_infos.change_24h)
                                return v === 0 ? '-' : General.formatPercent(v) + " (24hr)"
                            }
                            visible: text_value !== "-"
                            font.pixelSize: headerSmallFont
                            color: DexTheme.getValueColor(current_ticker_infos.change_24h)
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Balance
                    ColumnLayout
                    {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        spacing: 5

                        DexLabel
                        {
                            id: balance
                            Layout.alignment: Qt.AlignHCenter
                            text_value: qsTr("Balance")
                            font.pixelSize: name.font.pixelSize
                            color: headerTitleColor
                        }

                        DexLabel
                        {
                            id: name_value
                            Layout.alignment: Qt.AlignHCenter
                            text_value: General.formatCrypto("", current_ticker_infos.balance, "")
                            font.pixelSize: headerTextFont
                            color: headerTextColor
                            privacy: true
                        }

                        DexLabel
                        {
                            id: fiat_value
                            Layout.alignment: Qt.AlignHCenter
                            text_value: General.formatFiat("", current_ticker_infos.fiat_amount, API.app.settings_pg.current_currency)
                            visible: current_ticker_infos.fiat_amount != 0
                            font.pixelSize: headerTextFont
                            color: headerTextColor
                            privacy: true

                        }
                    }

                    Item { Layout.fillWidth: true }

                    DefaultImage {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        opacity: 0.7
                        source: current_ticker_infos.qrcode_address
                        sourceSize.width: 80
                        sourceSize.height: 80
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
                    spacing: 2
                    
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
