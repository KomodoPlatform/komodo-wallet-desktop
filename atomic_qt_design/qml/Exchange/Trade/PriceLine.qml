import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

// Price
ColumnLayout {
    visible: hasValidPrice()

    property double price: !orderIsSelected() ? getCalculatedPrice() : preffered_order.price

    readonly property int fontSize: Style.textSizeSmall2
    readonly property int fontSizeBigger: Style.textSizeSmall4

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
