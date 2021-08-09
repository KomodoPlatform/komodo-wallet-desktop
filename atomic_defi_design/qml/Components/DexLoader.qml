import QtQuick 2.15

Loader {
    property
    var onLoadComplete: () => {}

    onLoaded: {
        onLoadComplete()
        onLoadComplete = () => {}
    }

    asynchronous: true
    visible: status === Loader.Ready
}