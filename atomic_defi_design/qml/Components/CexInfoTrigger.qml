import QtQuick 2.15

DefaultMouseArea {
    id: mouse_area
    property bool no_default: true
    property string toolTip: qsTr("Price oracle powered by Band Protocol")
    anchors.fill: parent
    onClicked: no_default? cex_rates_modal.open() : ()=>{}
    hoverEnabled: true

    DefaultTooltip {
        visible: mouse_area.containsMouse

        delay: 500

        contentItem: DefaultText {
            text_value: mouse_area.toolTip
            wrapMode: DefaultText.Wrap
            width: 300
        }
    }
}
