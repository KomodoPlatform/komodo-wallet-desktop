import QtQuick 2.12

ListView {
    function show(text, duration) {
        model.insert(0, {text: text, duration: duration});
    }

    id: root

    z: Infinity
    spacing: 5
    anchors.fill: parent
    anchors.bottomMargin: 10
    verticalLayoutDirection: ListView.BottomToTop

    interactive: false

    displaced: Transition {
        NumberAnimation {
            properties: "y"
            easing.type: Easing.InOutQuad
        }
    }
    
    delegate: Toast {
        Component.onCompleted: show(text, typeof duration === "undefined" ? undefined : duration)
    }

    model: ListModel {id: model}
}
