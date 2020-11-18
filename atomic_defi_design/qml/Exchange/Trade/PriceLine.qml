import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Components"
import "../../Constants"

// Price
RowLayout {
    // Will move to backend
    readonly property double price: orderIsSelected() ? preffered_order.price : getCalculatedPrice()
    readonly property bool invalid_cex_price: parseFloat(cex_price) === 0
    readonly property double price_diff: invalid_cex_price ? 0 : 100 * (1 - parseFloat(price) / parseFloat(cex_price)) *
                                                                                                            (sell_mode ? 1 : -1)

    readonly property int fontSize: Style.textSizeSmall1
    readonly property int fontSizeBigger: Style.textSizeSmall2
    readonly property int line_scale: getComparisonScale(price_diff)

    readonly property bool price_entered: hasValidPrice()

    function getComparisonScale(value) {
        return Math.min(Math.pow(10, General.getDigitCount(value)), 1000000000)
    }

    function limitDigits(value) {
        return parseFloat(value.toFixed(2))
    }

    DefaultText {
        visible: !price_entered && invalid_cex_price
        Layout.alignment: Qt.AlignHCenter
        text_value: qsTr("Set swap price for evaluation")
        font.pixelSize: fontSizeBigger
    }


    ColumnLayout {
        visible: price_entered
        Layout.alignment: Qt.AlignHCenter

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: qsTr("Exchange rate") + (orderIsSelected() ? (" (" + qsTr("Selected") + ")") : "")
            font.pixelSize: fontSize
        }

        // Price reversed
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: General.formatCrypto("", "1", right_ticker) + " = " + General.formatCrypto("", General.formatDouble(1 / parseFloat(price)), left_ticker)
            font.pixelSize: fontSizeBigger
            font.weight: Font.Medium
        }

        // Price
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: General.formatCrypto("", price, right_ticker) + " = " + General.formatCrypto("", "1", left_ticker)
            font.pixelSize: fontSize
        }
    }


    // Price Comparison
    ColumnLayout {
        visible: price_entered && !invalid_cex_price
        Layout.alignment: Qt.AlignHCenter

        DefaultText {
            id: price_diff_text
            Layout.topMargin: 10
            Layout.bottomMargin: Layout.topMargin
            Layout.alignment: Qt.AlignHCenter
            color: price_diff <= 0 ? Style.colorGreen : Style.colorRed
            text_value: (price_diff > 0 ? qsTr("Expensive") : qsTr("Expedient")) + ":&nbsp;&nbsp;&nbsp;&nbsp;" + qsTr("%1 compared to CEX", "PRICE_DIFF%").arg("<b>" + General.formatPercent(limitDigits(price_diff)) + "</b>")
            font.pixelSize: fontSize
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            DefaultText {
                text_value: General.formatPercent(line_scale)
                font.pixelSize: fontSize
            }

            GradientRectangle {
                width: 125
                height: 6

                start_color: Style.colorGreen
                end_color: Style.colorRed

                AnimatedRectangle {
                    width: 4
                    height: parent.height * 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 0.5 * parent.width * Math.min(Math.max(price_diff / line_scale, -1), 1)
                }
            }

            DefaultText {
                text_value: General.formatPercent(-line_scale)
                font.pixelSize: fontSize
            }
        }
    }





    // CEXchange
    ColumnLayout {
        visible: !invalid_cex_price
        Layout.alignment: Qt.AlignHCenter

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: General.cex_icon + " " + qsTr("CEXchange rate")
            font.pixelSize: fontSize

            CexInfoTrigger {}
        }

        // Price reversed
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: General.formatCrypto("", "1", right_ticker) + " = " + General.formatCrypto("", General.formatDouble(1 / parseFloat(cex_price)), left_ticker)
            font.pixelSize: fontSizeBigger
            font.weight: Font.Medium
        }

        // Price
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: General.formatCrypto("", cex_price, right_ticker) + " = " + General.formatCrypto("", "1", left_ticker)
            font.pixelSize: fontSize
        }
    }
}
