import QtQuick 2.15

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
