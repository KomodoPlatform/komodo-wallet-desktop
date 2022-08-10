import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtWebEngine 1.8

import "../../Components"
import "../../Constants"
import Dex.Themes 1.0 as Dex

Item
{
    id: root

    readonly property string theme: Dex.CurrentTheme.getColorMode() === Dex.CurrentTheme.ColorMode.Dark ? "dark" : "light"
    property string loaded_symbol
    property bool pair_supported: false
    onPair_supportedChanged: if (!pair_supported) webEngineViewPlaceHolder.visible = false

    function loadChart(right_ticker, left_ticker, force = false, source="nomics")
    {
        let chart_html = ""
        let symbol = ""

        if (source == "nomics")
        {
            let right_ticker_full = General.coinName(right_ticker)
            let right_ticker_id = General.getNomicsId(right_ticker)
            let left_ticker_id = General.getNomicsId(left_ticker)

            if (right_ticker_id != "" && left_ticker_id != "")
            {
                symbol = right_ticker_id+"-"+left_ticker_id

                pair_supported = true
                if (symbol === loaded_symbol && !force)
                {
                    webEngineViewPlaceHolder.visible = true
                    return
                }

                loaded_symbol = symbol

                chart_html = `
                <style>
                body { margin: 0; }
                </style>

                <!-- Nomics Widget BEGIN -->
                <div class="nomics-ticker-widget" data-name="${right_ticker_full}" data-base="${right_ticker_id}" data-quote="${left_ticker_id}"></div>
                <script src="https://widget.nomics.com/embed.js"></script>
                <!-- Nomics Widget END -->`
            }
        }

        if (chart_html == "")
        {
            const pair = atomic_qt_utilities.retrieve_main_ticker(left_ticker) + "/" + atomic_qt_utilities.retrieve_main_ticker(right_ticker)
            const pair_reversed = atomic_qt_utilities.retrieve_main_ticker(right_ticker) + "/" + atomic_qt_utilities.retrieve_main_ticker(left_ticker)

            // Try checking if pair/reversed-pair exists
            symbol = General.supported_pairs[pair]
            if (!symbol) symbol = General.supported_pairs[pair_reversed]

            if (!symbol)
            {
                pair_supported = false
                return
            }

            pair_supported = true

            if (symbol === loaded_symbol && !force)
            {
                webEngineViewPlaceHolder.visible = true
                return
            }

            loaded_symbol = symbol

            let chart_html = `
            <style>
            body { margin: 0; }
            </style>

            <!-- TradingView Widget BEGIN -->
            <div class="tradingview-widget-container">
            <div id="tradingview_af406"></div>
            <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
            <script type="text/javascript">
            new TradingView.widget(
            {
            "timezone": "Etc/UTC",
            "locale": "en",
            "autosize": true,
            "symbol": "${symbol}",
            "interval": "D",
            "theme": "${theme}",
            "style": "1",
            "enable_publishing": false,
            "save_image": false
            }
            );
            </script>
            </div>
            <!-- TradingView Widget END -->`
        }
        dashboard.webEngineView.loadHtml(chart_html)
    }

    Component.onCompleted:
    {
        try
        {
            loadChart(left_ticker?? atomic_app_primary_coin,
                      right_ticker?? atomic_app_secondary_coin)
        }
        catch (e) { console.error(e) }
    }

    RowLayout
    {
        anchors.fill: parent
        visible: !webEngineViewPlaceHolder.visible

        DefaultBusyIndicator
        {
            visible: pair_supported
            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: -15
            Layout.rightMargin: Layout.leftMargin*0.75
            scale: 0.5
        }

        DefaultText
        {
            visible: pair_supported
            text_value: qsTr("Loading market data") + "..."
        }

        DefaultText
        {
            visible: !pair_supported
            text_value: qsTr("There is no chart data for this pair yet")
            Layout.topMargin: 30
            Layout.alignment: Qt.AlignCenter
        }
    }

    Item
    {
        id: webEngineViewPlaceHolder
        anchors.fill: parent
        visible: false

        Component.onCompleted:
        {
            dashboard.webEngineView.parent = webEngineViewPlaceHolder
            dashboard.webEngineView.anchors.fill = webEngineViewPlaceHolder
        }
        Component.onDestruction:
        {
            dashboard.webEngineView.visible = false
            dashboard.webEngineView.stop()
        }
        onVisibleChanged: dashboard.webEngineView.visible = visible

        Connections
        {
            target: dashboard.webEngineView

            function onLoadingChanged(webEngineLoadReq)
            {
                if (webEngineLoadReq.status === WebEngineView.LoadSucceededStatus)
                {
                    webEngineViewPlaceHolder.visible = true
                }
                else webEngineViewPlaceHolder.visible = false
            }
        }
    }

    Connections
    {
        target: app
        function onPairChanged()
        {
            root.loadChart(left_ticker, right_ticker)
        }
    }

    Connections
    {
        target: Dex.CurrentTheme
        function onThemeChanged()
        {
            loadChart(left_ticker?? atomic_app_primary_coin,
                      right_ticker?? atomic_app_secondary_coin,
                      true)
        }
    }
}
