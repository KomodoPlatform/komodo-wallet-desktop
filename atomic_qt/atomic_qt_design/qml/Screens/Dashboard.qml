import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

Item {
    ColumnLayout {
        anchors.centerIn: parent

        DefaultText {
            text: "Very Minimalistic Dashboard"
        }

        Button {
            text: "Print Coins"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            onClicked: () => {
                console.log(JSON.stringify(MockAPI.getAtomicApp().enabled_coins, null, 4))
            }
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
