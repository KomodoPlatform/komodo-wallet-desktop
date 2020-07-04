import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

// Price
DefaultText {
    Layout.alignment: Qt.AlignHCenter
    text_value: API.get().empty_string + (!hasValidPrice() ? '' :
         (!orderIsSelected() ? qsTr("Price") : qsTr("Selected Price")) + ": " +
          General.formatCrypto("", !orderIsSelected() ? getCalculatedPrice() : preffered_order.price, getTicker(false)))
}
