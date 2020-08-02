import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

// Price
RowLayout {
    readonly property double price: !orderIsSelected() ? getCalculatedPrice() : preffered_order.price
    readonly property bool invalid_cex_price: parseFloat(cex_price) === 0
    readonly property double price_diff: invalid_cex_price ? 0 : 100 * (1 - parseFloat(price) / parseFloat(cex_price))

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
        text_value: API.get().empty_string + (qsTr("Fill the amounts to see the price information"))
        font.pixelSize: fontSize
    }


    ColumnLayout {
        visible: price_entered
        Layout.alignment: Qt.AlignHCenter

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + (qsTr("Exchange rate") + (orderIsSelected() ? (" (" + qsTr("Selected") + ")") : ""))
            font.pixelSize: fontSize
        }

        // Price reversed
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(false) + " = " + General.formatCrypto("", General.formatDouble(1 / parseFloat(price)), getTicker(true)))
            font.pixelSize: fontSizeBigger
            font.bold: true
        }

        // Price
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(true) + " = " + General.formatCrypto("", price, getTicker(false)))
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
            text_value: API.get().empty_string + ((price_diff > 0 ? qsTr("Expensive") : qsTr("Expedient")) + ":&nbsp;&nbsp;&nbsp;&nbsp;" + qsTr("%1 compared to CEX", "PRICE_DIFF%").arg("<b>" + General.formatPercent(limitDigits(price_diff)) + "</b>"))
            font.pixelSize: fontSize
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            DefaultText {
                text_value: API.get().empty_string + (General.formatPercent(line_scale))
                font.pixelSize: fontSize
            }

            GradientRectangle {
                width: 125
                height: 6

                start_color: Style.colorGreen
                end_color: Style.colorRed

                Rectangle {
                    width: 4
                    height: parent.height * 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 0.5 * parent.width * Math.min(Math.max(price_diff / line_scale, -1), 1)
                }
            }

            DefaultText {
                text_value: API.get().empty_string + (General.formatPercent(-line_scale))
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
            text_value: API.get().empty_string + (General.cex_icon + " " + qsTr("CEXchange rate"))
            font.pixelSize: fontSize

            CexInfoTrigger {}
        }

        // Price reversed
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(false) + " = " + General.formatCrypto("", General.formatDouble(1 / parseFloat(cex_price)), getTicker(true)))
            font.pixelSize: fontSizeBigger
            font.bold: true
        }

        // Price
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(true) + " = " + General.formatCrypto("", cex_price, getTicker(false)))
            font.pixelSize: fontSize
        }
    }
}
