import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"
import "../Wallet"
import "../Exchange"
import "../Sidebar"

Item {
    id: dashboard
    Layout.fillWidth: true

    property int current_page: General.idx_dashboard_wallet

    // Left side
    Rectangle {
        color: Style.colorTheme6
        width: parent.width - sidebar.width
        height: parent.height

        StackLayout {
            currentIndex: current_page

            anchors.fill: parent

            transformOrigin: Item.Center


            Wallet {

            }

            Exchange {

            }

            DefaultText {
                text: qsTr("News")
            }

            DefaultText {
                text: qsTr("DApps")
            }

            DefaultText {
                text: qsTr("Settings")
            }
        }
    }

    // Sidebar, right side
    Rectangle {
        id: sidebar
        color: Style.colorTheme8
        width: 150
        height: parent.height
        x: parent.width - width

        Image {
            source: General.image_path + "komodo-icon.png"
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.width * 0.25
            transformOrigin: Item.Center
            width: 64
            fillMode: Image.PreserveAspectFit
        }

        Sidebar {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Modals
    EnableCoinModal {
        id: enable_coin_modal
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:1200}
}
##^##*/
