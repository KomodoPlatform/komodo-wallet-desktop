import QtQuick 2.15

Loader {
    id: root

    function open() {
        if(active) item.open()
        else active = true
    }

    function close() {
        if(active) item.close()
        else active = false
    }

    active: false

    onLoaded: item.open()

    Connections {
        target: root.item

        function onClosed() { root.active = false }
    }
}
