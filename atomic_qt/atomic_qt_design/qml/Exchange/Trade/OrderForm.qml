import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Right side
Rectangle {
    property string action
    property string base
    property string rel

    property bool sell

    color: Style.colorTheme7
    radius: Style.rectangleCornerRadius

    ColumnLayout {
        width: parent.width

        DefaultText {
            id: title

            Layout.leftMargin: 15
            Layout.topMargin: 15
            Layout.bottomMargin: 5

            text: (sell ? qsTr("Sell") : qsTr("Buy")) + " " + base
            font.pointSize: Style.textSize2
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite5
        }

        // Volume
        AmountField {
            id: input_volume
            Layout.topMargin: 10
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            title: "Volume"
        }

        // Price
        AmountField {
            id: input_price
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            title: "Price"
        }
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
