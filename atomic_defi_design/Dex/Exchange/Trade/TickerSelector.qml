import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "../../Components"
import "../../Constants"

SweetDexComboBox
{
    id: combo

    function renewIndex()
    {
        combo.currentIndex = combo.indexOfValue(ticker)
    }

    property bool left_side: false
    property var ticker_list
    property string ticker

    // Indicates user input, when list changes, index stays the same so we know it's not user input
    property bool index_changed: false

    enabled: !block_everything

    model: ticker_list
    valueRole: "ticker"

    onTickerChanged: renewIndex()
    Component.onCompleted: renewIndex()

    onCurrentIndexChanged: combo.index_changed = true
    onCurrentValueChanged:
    {
        // User input
        if(combo.index_changed)
        {
            combo.index_changed = false
            // Set the ticker
            if (currentValue !== undefined)
                setPair(left_side, currentValue)
        }
        // List change
        else
        {
            // Correct the index
            if (currentText.indexOf(ticker) === -1)
            {
                const target_index = indexOfValue(ticker)
                if(currentIndex !== target_index)
                    currentIndex = target_index
            }
        }
    }
}
