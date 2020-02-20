import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Right side
Rectangle {
    property bool my_side: false

    function getTicker() {
        if(combo.currentIndex === -1) return ''

        return getCoins()[combo.currentIndex].ticker
    }

    function setTicker(ticker) {
        combo.currentIndex = getCoins().map(c => c.ticker).indexOf(ticker)
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

    RowLayout {
        Image {
            Layout.leftMargin: combo.Layout.rightMargin
            source: General.coinIcon(getTicker(combo))
            Layout.preferredWidth: 32
            Layout.preferredHeight: Layout.preferredWidth
        }

        ComboBox {
            id: combo
            Layout.preferredWidth: 125
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.rightMargin: 15

            model: General.getTickers(getCoins())
            onCurrentTextChanged: {
                setPair()
                if(my_side) prev_base = getTicker(combo)
                else prev_rel = getTicker(combo)

                capVolume()
            }
        }

        AmountField {
            id: input_volume
            Layout.preferredWidth: field.font.pointSize*10
            Layout.rightMargin: combo.Layout.rightMargin
            Layout.topMargin: Layout.rightMargin
            Layout.bottomMargin: Layout.rightMargin
            title: my_side ? qsTr("Sell") : qsTr("Receive")
            field.placeholderText: my_side ? qsTr("Amount to sell") : qsTr("Amount to receive")
            field.onTextChanged: capVolume()
        }

        Button {
            Layout.rightMargin: combo.Layout.rightMargin
            Layout.topMargin: Layout.rightMargin
            Layout.bottomMargin: Layout.rightMargin
            visible: my_side
            text: qsTr("MAX")
            onClicked: input_volume.field.text = getMaxVolume()
        }
    }
}
