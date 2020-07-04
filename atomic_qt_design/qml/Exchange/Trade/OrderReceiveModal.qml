import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root_modal

    function getOrderCount(ticker) {
        if(orderbook_model === undefined) return 0

        const book = orderbook_model[ticker]
        if(book === undefined) return 0

        return book.length
    }

    width: 500

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: API.get().empty_string + (qsTr("Receive"))
        }

        // Search input
        DefaultTextField {
            id: input_coin_filter

            Layout.fillWidth: true
            placeholderText: API.get().empty_string + (qsTr("Search"))
            selectByMouse: true
        }

        // List
        DefaultListView {
            id: list
            implicitHeight: 600

            model: General.filterCoins(getFilteredCoins().sort((a, b) => getOrderCount(b.ticker) - getOrderCount(a.ticker)), input_coin_filter.text)

            delegate: Rectangle {
                color: mouse_area.containsMouse ? Style.colorTheme4 : "transparent"

                width: modal_layout.width
                height: 50

                MouseArea {
                    id: mouse_area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        setTicker(model.modelData.ticker)
                        root_modal.close()
                        if(getOrderCount(model.modelData.ticker) === 0) {

                        }
                        else {
                            orderbook_modal.open()
                        }
                    }
                }

                // Icon
                Image {
                    id: icon
                    anchors.left: parent.left
                    anchors.leftMargin: 20

                    source: General.coinIcon(model.modelData.ticker)
                    fillMode: Image.PreserveAspectFit
                    width: Style.textSize2
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Name
                DefaultText {
                    anchors.left: icon.right
                    anchors.leftMargin: Style.iconTextMargin

                    text_value: API.get().empty_string + (model.modelData.name + " (" + model.modelData.ticker + ")" + " - " +
                          (getOrderCount(model.modelData.ticker) === 0 ? qsTr("Click to create an order")  :
                                                   qsTr("Click to see %n order(s)", "", getOrderCount(model.modelData.ticker))))
                    anchors.verticalCenter: parent.verticalCenter

                    color: getOrderCount(model.modelData.ticker) === 0 ? Style.colorWhite1 : Style.colorTheme0
                }
            }
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root_modal.close()
            }
        }
    }
}
