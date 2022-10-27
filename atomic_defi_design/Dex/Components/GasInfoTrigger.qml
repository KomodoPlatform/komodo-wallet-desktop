import QtQuick 2.15

DefaultMouseArea {
    id: mouse_area
    property bool no_default: true
    anchors.fill: parent
    onClicked: no_default ? gas_info_modal.open() : () => {}
}
