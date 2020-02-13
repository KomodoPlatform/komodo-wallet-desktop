import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

DefaultText {
    property int dashboard_index

    property bool hovered: false

    // Override
    function preClick() {}

    id: txt
    font.pointSize: Style.textSize2
    font.family: "Montserrat"
    font.bold: exchange.current_page === dashboard_index
    color: font.bold ? Style.colorWhite1 : hovered ? Style.colorWhite4 : Style.colorWhite5

    MouseArea {
        hoverEnabled: true
        onHoveredChanged: hovered = containsMouse
        width: parent.width
        height: parent.height
        onClicked: function() {
            exchange.current_page = dashboard_index
            preClick()
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
