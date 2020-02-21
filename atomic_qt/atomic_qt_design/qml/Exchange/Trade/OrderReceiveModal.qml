import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root

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
            title: qsTr("Receive")
        }

        // Search input
        TextField {
            id: input_coin_filter

            Layout.fillWidth: true
            placeholderText: qsTr("Search")
            selectByMouse: true
        }

        // List
        ListView {
            id: list
            ScrollBar.vertical: ScrollBar {}
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: contentItem.childrenRect.height

            model: General.filterCoins(getFilteredCoins().sort((a, b) => getOrderCount(b.ticker) - getOrderCount(a.ticker)), input_coin_filter.text)
            clip: true

            delegate: Rectangle {
                property bool hovered: false

                color: hovered ? Style.colorTheme4 : "transparent"

                width: modal_layout.width
                height: 50

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: hovered = containsMouse
                    onClicked: {
                        setTicker(model.modelData.ticker)
                        root.close()
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

                    text: model.modelData.name + " (" + model.modelData.ticker + ")" + " - " +
                          (getOrderCount(model.modelData.ticker) === 0 ? qsTr("Click to create an order")  :
                                                   qsTr("Click to see ") + getOrderCount(model.modelData.ticker) + qsTr(" order") +
                                                                            (getOrderCount(model.modelData.ticker) > 1 ? qsTr("s") : ""))
                    anchors.verticalCenter: parent.verticalCenter

                    color: getOrderCount(model.modelData.ticker) === 0 ? Style.colorWhite1 : Style.colorTheme0
                }
            }
        }

        // Buttons
        RowLayout {
            Button {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }
        }
    }
}
