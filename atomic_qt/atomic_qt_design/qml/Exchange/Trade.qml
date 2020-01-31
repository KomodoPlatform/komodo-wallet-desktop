import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

Item {
    id: exchange_trade

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Layout.fillWidth: true

        spacing: 20

        function convertToFullName(coins) {
            return coins.map(c => c.name + " (" + c.ticker + ")")
        }

        // Base
        ComboBox {
            id: combo_base
            width: 400
            model: convertToFullName(API.get().enabled_coins)
        }

        // Rel Base
        ComboBox {
            id: combo_rel
            width: 400
            //model: convertToFullName(API.get().enabled_coins.filter(c => c.ticker !== combo_base.model[combo_base.currentIndex]))
        }
    }
}








/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:1200}
}
##^##*/
