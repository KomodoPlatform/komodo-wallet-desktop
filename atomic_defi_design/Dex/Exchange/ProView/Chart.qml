import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtWebEngine 1.8

import "../../Components"
import "../../Constants"
import Dex.Themes 1.0 as Dex

Widget
{
    id: root
    title: qsTr("Chart")
    background: null
    margins: 0

    readonly property string theme: Dex.CurrentTheme.getColorMode() === Dex.CurrentTheme.ColorMode.Dark ? "dark" : "light"
    property string loaded_symbol
    property bool pair_supported: false
    onPair_supportedChanged: if (!pair_supported) webEngineViewPlaceHolder.visible = false

    function loadChart(base, rel, force = false)
    {
        const pair = atomic_qt_utilities.retrieve_main_ticker(base) + "/" + atomic_qt_utilities.retrieve_main_ticker(rel)
        const pair_reversed = atomic_qt_utilities.retrieve_main_ticker(rel) + "/" + atomic_qt_utilities.retrieve_main_ticker(base)

        // Try checking if pair/reversed-pair exists
        let symbol = General.supported_pairs[pair]
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

        dashboard.webEngineView.loadHtml(`
            <style>
            body { margin: 0; background: ${Dex.CurrentTheme.backgroundColor} }
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
            <!-- TradingView Widget END -->`)
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
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignCenter
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
        Layout.fillWidth: true
        Layout.fillHeight: true
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
        function onPairChanged(base, rel)
        {
            root.loadChart(base, rel)
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
