import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Components"
import "../../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

ColumnLayout
{
    readonly property string price: non_null_price
    readonly property string price_reversed: API.app.trading_pg.price_reversed
    readonly property string cex_price: API.app.trading_pg.cex_price
    readonly property string cex_price_reversed: API.app.trading_pg.cex_price_reversed
    readonly property string cex_price_diff: API.app.trading_pg.cex_price_diff
    readonly property bool invalid_cex_price: API.app.trading_pg.invalid_cex_price
    readonly property bool price_entered: !General.isZero(non_null_price)

    readonly property int fontSize: Style.textSizeSmall1
    readonly property int fontSizeBigger: Style.textSizeSmall2
    readonly property int line_scale: getComparisonScale(cex_price_diff)

    function getComparisonScale(value)
    {
        return Math.min(Math.pow(10, General.getDigitCount(parseFloat(value))), 1000000000)
    }

    function limitDigits(value)
    {
        return parseFloat(General.formatDouble(value, 2))
    }

    spacing: 35

    DefaultText
    {
        visible: !price_entered && invalid_cex_price
        Layout.alignment: Qt.AlignHCenter
        text_value: qsTr("Set swap price for evaluation")
        font.pixelSize: fontSizeBigger
    }

    RowLayout
    {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        ColumnLayout
        {
            visible: price_entered
            DefaultText
            {
                text_value: qsTr("Exchange rate") + (preffered_order.price !== undefined ? (" (" + qsTr("Selected") + ")") : "")
                font.pixelSize: fontSize
            }

            // Price reversed
            DefaultText
            {
                text_value: General.formatCrypto("", "1", right_ticker) + " = " + General.formatCrypto("", price_reversed, left_ticker)
                font.pixelSize: fontSizeBigger
                font.weight: Font.Medium
            }

            // Price
            DefaultText
            {
                text_value: General.formatCrypto("", price, right_ticker) + " = " + General.formatCrypto("", "1", left_ticker)
                font.pixelSize: fontSize
            }
        }

        Item { Layout.fillWidth: true }

        ColumnLayout
        {
            visible: !invalid_cex_price

            DefaultText
            {
                Layout.alignment: Qt.AlignRight
                text_value: General.cex_icon + " " + qsTr("CEXchange rate")
                font.pixelSize: fontSize

                CexInfoTrigger {}
            }

            // Price reversed
            DefaultText
            {
                Layout.alignment: Qt.AlignRight
                text_value: General.formatCrypto("", "1", right_ticker) + " = " + General.formatCrypto("", cex_price_reversed, left_ticker)
                font.pixelSize: fontSizeBigger
                font.weight: Font.Medium
            }

            // Price
            DefaultText
            {
                Layout.alignment: Qt.AlignRight
                text_value: General.formatCrypto("", cex_price, right_ticker) + " = " + General.formatCrypto("", "1", left_ticker)
                font.pixelSize: fontSize
            }
        }
    }
    

    // Price Comparison
    ColumnLayout
    {
        visible: price_entered && !invalid_cex_price
        Layout.alignment: Qt.AlignHCenter

        RowLayout
        {
            Layout.fillWidth: true

            GradientRectangle
            {
                Layout.fillWidth: true
                Layout.preferredHeight: 6

                start_color: Dex.CurrentTheme.okColor
                end_color: Dex.CurrentTheme.noColor

                AnimatedRectangle
                {
                    width: 4
                    height: parent.height * 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 0.5 * parent.width * Math.min(Math.max(parseFloat(cex_price_diff) / line_scale, -1), 1)
                }

                DefaultText
                {
                    text_value: General.formatPercent(line_scale)
                    font.pixelSize: fontSize
                    anchors.top: parent.top
                    anchors.topMargin: -15
                }

                DefaultText
                {
                    text_value: General.formatPercent(-line_scale)
                    font.pixelSize: fontSize
                    anchors.top: parent.top
                    anchors.topMargin: -15
                    anchors.right: parent.right
                }
            }
        }

        DefaultText
        {
            id: price_diff_text
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
            color: parseFloat(cex_price_diff) <= 0 ? Dex.CurrentTheme.okColor : Dex.CurrentTheme.noColor
            text_value: (parseFloat(cex_price_diff) > 0 ? qsTr("Expensive") : qsTr("Expedient")) + ":&nbsp;&nbsp;&nbsp;&nbsp;" + qsTr("%1 compared to CEX", "PRICE_DIFF%").arg("<b>" + General.formatPercent(limitDigits(cex_price_diff)) + "</b>")
            font.pixelSize: fontSize
        }
    }
}
