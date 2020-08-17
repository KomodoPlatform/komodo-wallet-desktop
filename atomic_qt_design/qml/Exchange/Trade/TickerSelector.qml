import QtQuick 2.14
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

        enabled: !block_everything

        model: ticker_list
        textRole: "display"
        valueRole: "ticker"

        property bool index_changed: false
        onCurrentIndexChanged: {
            // Save index change
            index_changed = true
        }

        onCurrentTextChanged: {
            // Set the original coin if it's not user input/backend, because index doesn't change, we know that it's the change of the list
            if(!index_changed && currentText.indexOf(ticker) === -1)
                currentIndex = indexOfValue(ticker)

            displayText = currentText
        }

        onCurrentValueChanged: {
            // Reset index change
            index_changed = false
            setPair(left_side, currentValue)
        }

        Layout.fillWidth: true
    }
}
