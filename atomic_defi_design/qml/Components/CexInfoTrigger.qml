import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Constants"

DefaultMouseArea {
    id: mouse_area
    anchors.fill: parent
    onClicked: cex_rates_modal.open()
    hoverEnabled: true

    DefaultTooltip {
        visible: mouse_area.containsMouse

        delay: 500

        contentItem: DefaultText {
            text_value: qsTr("Price oracle powered by Band Protocol")
        }
    }
}
