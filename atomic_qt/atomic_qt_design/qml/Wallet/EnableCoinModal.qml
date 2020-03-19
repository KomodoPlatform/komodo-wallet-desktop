import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root

    property var selected_to_enable: ({})

    function reset() {
        selected_to_enable = {}
        input_coin_filter.text = ""
    }

    function prepareAndOpen() {
        reset()
        root.open()
    }

    function markToEnable(ticker, enabled) {
        if(enabled) selected_to_enable[ticker] = true
        else delete selected_to_enable[ticker]

        selected_to_enable = selected_to_enable
    }

    function enableCoins() {
        API.get().enable_coins(Object.keys(selected_to_enable))
        root.close()
    }

    // Inside modal
    ColumnLayout {
        id: modal_layout
        ModalHeader {
            title: API.get().empty_string + (qsTr("Enable coins"))
        }

        // Search input
        TextField {
            id: input_coin_filter

            Layout.fillWidth: true
            placeholderText: API.get().empty_string + (qsTr("Search"))
            selectByMouse: true
        }

        Flickable {
            width: 350
            height: 400
            contentWidth: col.width
            contentHeight: col.height
            clip: true
            ScrollBar.vertical: ScrollBar { }

            Column {
                id: col

                CoinList {
                    group_title: API.get().empty_string + qsTr("Select all coins")
                    model: General.filterCoins(API.get().enableable_coins, input_coin_filter.text)
                }
            }
        }


        // Info text
        DefaultText {
            visible: API.get().enableable_coins.length === 0

            text: API.get().empty_string + (qsTr("All coins are already enabled!"))
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            }
            PrimaryButton {
                visible: API.get().enableable_coins.length > 0
                enabled: Object.keys(selected_to_enable).length > 0
                text: API.get().empty_string + (qsTr("Enable"))
                Layout.fillWidth: true
                onClicked: enableCoins()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
