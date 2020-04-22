import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

DefaultText {
    property int dashboard_index

    // Override
    property var onClick: () => {}

    id: txt
    font.pixelSize: Style.textSize2
    font.family: "Montserrat"
    font.bold: exchange.current_page === dashboard_index
    color: font.bold ? Style.colorWhite1 : mouse_area.containsMouse ? Style.colorWhite4 : Style.colorWhite5

    MouseArea {
        id: mouse_area
        hoverEnabled: true
        width: parent.width
        height: parent.height
        onClicked: function() {
            exchange.current_page = dashboard_index
            onClick()
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
