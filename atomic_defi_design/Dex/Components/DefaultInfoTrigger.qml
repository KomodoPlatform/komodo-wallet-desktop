import QtQuick 2.15

DefaultMouseArea {
    id: mouse_area
    property bool no_default: true
    property var triggerModal
    anchors.fill: parent
    onClicked: no_default ? triggerModal.open() : () => {}
}
