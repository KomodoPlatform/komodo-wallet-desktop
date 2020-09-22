import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.0

import "../../Components"
import "../../Constants"

RowLayout {
    id: root

    spacing: 5
    layoutDirection: left_side ? Qt.LeftToRight : Qt.RightToLeft

    property bool left_side: false
    property var ticker_list
    property string ticker

    function renewIndex() {
        combo.currentIndex = combo.indexOfValue(ticker)
    }

    onTickerChanged: renewIndex()

    DexComboBox {
        id: combo

        enabled: !block_everything

        model: ticker_list

        valueRole: "ticker"

        property bool index_changed: false

        onCurrentIndexChanged: combo.index_changed = true

        onDisplayTextChanged: {
            if(currentText.indexOf(ticker) === -1) {
                const target_index = indexOfValue(ticker)
                if(currentIndex !== target_index) {
                    if(!combo.index_changed) {
                        currentIndex = target_index
                    }
                    else combo.index_changed = false
                }
            }
        }

        onCurrentValueChanged: {
            combo.index_changed = false
            if(currentValue !== undefined) setPair(left_side, currentValue)
        }

        Layout.fillWidth: true
    }
}
