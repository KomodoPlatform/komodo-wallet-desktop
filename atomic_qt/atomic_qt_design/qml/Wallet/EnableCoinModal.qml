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
    }

    function prepareAndOpen() {
        reset()
        root.open()
    }

    function markToEnable(ticker) {
      if(selected_to_enable[ticker] === undefined) selected_to_enable[ticker] = true
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
            title: qsTr("Enable coins")
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
            ScrollBar.vertical: ScrollBar {}
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: contentItem.childrenRect.height
            Layout.maximumHeight: 300

            model: General.filterCoins(API.get().enableable_coins, input_coin_filter.text)
            clip: true

            delegate: Rectangle {
                property bool hovered: false

                color: selected_to_enable[model.modelData.ticker] ? Style.colorTheme2 : hovered ? Style.colorTheme4 : "transparent"

                width: 400
                height: 50

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: hovered = containsMouse
                    onClicked: markToEnable(model.modelData.ticker)
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

                    text: model.modelData.name + " (" + model.modelData.ticker + ")"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }


        // Info text
        DefaultText {
            visible: API.get().enableable_coins.length === 0

            text: qsTr("All coins are already enabled!")
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }
            PrimaryButton {
                visible: API.get().enableable_coins.length > 0
                enabled: Object.keys(selected_to_enable).length > 0
                text: qsTr("Enable")
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
