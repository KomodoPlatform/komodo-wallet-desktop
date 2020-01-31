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
        DefaultText {
            Layout.leftMargin: 15
            Layout.topMargin: 15

            id: title
            text: (sell ? qsTr("Sell") : qsTr("Buy")) + " " + base
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: Style.textSize2
        }
    }
}








