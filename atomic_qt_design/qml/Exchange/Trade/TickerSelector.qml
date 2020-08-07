import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.0

import "../../Components"
import "../../Constants"

RowLayout {
    id: root

    spacing: 5
    Layout.preferredWidth: 250
    layoutDirection: left_side ? Qt.LeftToRight : Qt.RightToLeft

    property bool left_side: false
    property var ticker_list
    property string ticker

    DefaultImage {
        source: General.coinIcon(ticker)
        Layout.preferredWidth: 32
        Layout.preferredHeight: Layout.preferredWidth
    }


    onTickerChanged: {
        combo.currentIndex = combo.indexOfValue(ticker)
    }

    DefaultComboBox {
        id: combo

        model: ticker_list
        textRole: "display"
        valueRole: "ticker"

        onCurrentValueChanged: setPair(left_side, currentValue)

        Layout.fillWidth: true
    }
}
