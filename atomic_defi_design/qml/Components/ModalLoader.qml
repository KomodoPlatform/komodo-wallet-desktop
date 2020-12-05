import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"

Loader {
    id: root

    function open() {
        if(active) item.open()
        else active = true
    }

    active: false

    onLoaded: item.open()

    Connections {
        target: root.item

        function onClosed() { root.active = false }
    }
}
