import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

DefaultText {
    property int dashboard_index
    property bool highlight: exchange.current_page === dashboard_index

    // Override
    property var onClick: () => {}

    id: txt
    font.pixelSize: Style.textSizeMid2
    font.family: Style.font_family
    font.weight: Font.Normal
    color: highlight ? Style.colorWhite1 : mouse_area.containsMouse ? Style.colorWhite4 : Style.colorWhite5

    DefaultMouseArea {
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
