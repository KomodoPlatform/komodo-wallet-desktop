import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Right side
Rectangle {
    property alias field: input_volume.field
    property bool my_side: false


    function isValid() {
        const fields_are_filled = input_volume.field.text !== '' && parseFloat(input_volume.field.text) > 0

        if(!my_side) return fields_are_filled

        const ticker = getTicker()

        // Try to fit once more
        if(!API.get().do_i_have_enough_funds(ticker, input_volume.field.text))
            capVolume()

        return fields_are_filled && API.get().do_i_have_enough_funds(ticker, input_volume.field.text)
    }

    function getTicker() {
        if(combo.currentIndex === -1) return ''

        return getCoins()[combo.currentIndex].ticker
    }

    function setTicker(ticker) {
        combo.currentIndex = getCoins().map(c => c.ticker).indexOf(ticker)
        capVolume()
    }

    function reset() {
        if(my_side) {
            input_volume.field.text = getMaxVolume()
        }
        else {
            input_volume.field.text = ''
        }
    }

    function getMaxVolume() {
        return API.get().get_balance(getTicker())
    }

    function capVolume() {
        if(my_side && input_volume.field.acceptableInput) {
            const cap = parseFloat(getMaxVolume())
            const amt = parseFloat(input_volume.field.text)
            if(amt > cap) input_volume.field.text = cap
        }
    }

    color: Style.colorTheme7
    radius: Style.rectangleCornerRadius

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    ColumnLayout {
        width: 300
        RowLayout {
            Image {
                Layout.leftMargin: combo.Layout.rightMargin
                source: General.coinIcon(getTicker(combo))
                Layout.preferredWidth: 32
                Layout.preferredHeight: Layout.preferredWidth
            }

            ComboBox {
                id: combo
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.rightMargin: 15

                model: my_side ? General.getTickersAndBalances(getCoins()): General.getTickers(getCoins())
                onCurrentTextChanged: {
                    setPair()
                    if(my_side) prev_base = getTicker(combo)
                    else prev_rel = getTicker(combo)

                    capVolume()
                }
            }
        }

        RowLayout {
            Button {
                Layout.leftMargin: combo.Layout.rightMargin
                Layout.topMargin: Layout.rightMargin
                Layout.bottomMargin: Layout.rightMargin
                visible: my_side
                text: qsTr("MAX")
                onClicked: input_volume.field.text = getMaxVolume()
            }

            AmountField {
                id: input_volume
                Layout.fillWidth: true
                Layout.rightMargin: combo.Layout.rightMargin
                Layout.leftMargin: Layout.rightMargin
                Layout.topMargin: Layout.rightMargin
                Layout.bottomMargin: Layout.rightMargin
                field.placeholderText: my_side ? qsTr("Amount to sell") : qsTr("Amount to receive")
                field.onTextChanged: capVolume()
            }
        }
    }
}
