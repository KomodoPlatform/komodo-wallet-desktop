import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

// Portfolio
Rectangle {
    id: portfolio
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Style.colorTheme7

    function reset() {
        updatePortfolio()
    }

    function inCurrentPage() {
        return  dashboard.inCurrentPage() &&
                dashboard.current_page === General.idx_dashboard_portfolio
    }

    property var portfolio_coins: ([])

    function updatePortfolio() {
        portfolio_coins = API.get().get_portfolio_informations()
        update_timer.running = true
    }

    Timer {
        id: update_timer
        running: false
        repeat: true
        interval: 5000
        onTriggered: {
            if(inCurrentPage()) updatePortfolio()
        }
    }

    // Coins list
    ListView {
        ScrollBar.vertical: ScrollBar {}
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: contentItem.childrenRect.width
        implicitHeight: contentItem.childrenRect.height
        clip: true

        model: portfolio_coins

        delegate: Rectangle {
            property bool hovered: false

            color: hovered ? Style.colorTheme5 : index % 2 == 0 ? Style.colorTheme6 : Style.colorTheme7
            width: portfolio.width
            height: 50

            // Click area
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: hovered = containsMouse
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button === Qt.RightButton) context_menu.popup()
                    else {
                        API.get().current_coin_info.ticker = model.modelData.ticker
                        dashboard.current_page = General.idx_dashboard_wallet
                    }
                }
                onPressAndHold: {
                    if (mouse.source === Qt.MouseEventNotSynthesized) context_menu.popup()
                }
            }

            // Right click menu
            Menu {
                id: context_menu
                Action {
                    text: "Disable " + model.modelData.ticker
                    onTriggered: API.get().disable_coins([model.modelData.ticker])
                    enabled: API.get().enabled_coins.length > 2
                }
            }

            // Icon
            Image {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: 20

                source: General.image_path + "coins/" + model.modelData.ticker.toLowerCase() + ".png"
                fillMode: Image.PreserveAspectFit
                width: Style.textSize2
                anchors.verticalCenter: parent.verticalCenter
            }

            // Name
            DefaultText {
                anchors.left: icon.right
                anchors.leftMargin: 5

                text: model.modelData.ticker
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}








/*##^##
Designer {
D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
