import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Right side
Rectangle {
    color: Style.colorTheme7
    radius: Style.rectangleCornerRadius

    ColumnLayout {
        width: parent.width

        DefaultText {
            Layout.topMargin: 10
            Layout.bottomMargin: 5

            id: title
            text: qsTr("Orderbook")
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: Style.textSize2
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
