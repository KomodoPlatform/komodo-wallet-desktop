import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

// Price
RowLayout {
    readonly property double price: !orderIsSelected() ? getCalculatedPrice() : preffered_order.price
    readonly property double expedient : 100 * (parseFloat(price) - parseFloat(cex_price))/parseFloat(cex_price)

    readonly property int fontSize: Style.textSizeSmall2
    readonly property int fontSizeBigger: Style.textSizeSmall4

    readonly property bool price_entered: hasValidPrice()

    spacing: 100

    ColumnLayout {
        visible: price_entered

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + (qsTr("Exchange rate") + (orderIsSelected() ? (" (" + qsTr("Selected") + ")") : ""))
            font.pixelSize: fontSize
        }

        // Price
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(true) + " = " + General.formatCrypto("", price, getTicker(false)))
            font.pixelSize: fontSizeBigger
            font.bold: true
        }

        // Price reversed
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(false) + " = " + General.formatCrypto("", General.formatDouble(1 / parseFloat(price)), getTicker(true)))
            font.pixelSize: fontSize
        }
    }


    // Expedient
    ColumnLayout {
        DefaultText {
            Layout.topMargin: 10
            Layout.bottomMargin: Layout.topMargin
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + (qsTr("Expedient") + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + qsTr("%1 compared to CEX", "EXPEDIENT").arg("<b>" + General.formatPercent(
                                                                                                                                        parseFloat(expedient.toFixed(2))
                                                                                                                                    ) + "</b>"))
            font.pixelSize: fontSize
        }
    }





    // CEXchange
    ColumnLayout {
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + (qsTr("CEXchange rate"))
            font.pixelSize: fontSize
        }

        // Price
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(true) + " = " + General.formatCrypto("", cex_price, getTicker(false)))
            font.pixelSize: fontSizeBigger
            font.bold: true
        }

        // Price reversed
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(false) + " = " + General.formatCrypto("", General.formatDouble(1 / parseFloat(cex_price)), getTicker(true)))
            font.pixelSize: fontSize
        }
    }
}
