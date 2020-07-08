import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

// Price
ColumnLayout {
    readonly property double price: !orderIsSelected() ? getCalculatedPrice() : preffered_order.price

    readonly property int fontSize: Style.textSizeSmall2
    readonly property int fontSizeBigger: Style.textSizeSmall4

    ColumnLayout {
        visible: hasValidPrice()

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


        // Expedient
        DefaultText {
            Layout.topMargin: 10
            Layout.bottomMargin: Layout.topMargin
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + (qsTr("Expedient") + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + qsTr("%1 compared to CEX", "EXPEDIENT").arg("<b>" + General.formatPercent(
                                                                                                                                        parseFloat((
                                                                                                                                            100 * (parseFloat(price) - parseFloat(cex_price))/parseFloat(cex_price)
                                                                                                                                         ).toFixed(2))
                                                                                                                                    ) + "</b>"))
            font.pixelSize: fontSize
        }
    }




    // CEXchange
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
