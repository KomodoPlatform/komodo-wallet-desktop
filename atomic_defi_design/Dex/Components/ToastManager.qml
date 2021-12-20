// This is a modified version of QML Toast Implementation of jonmcclung
// https://gist.github.com/jonmcclung/bae669101d17b103e94790341301c129

import QtQuick 2.15

ListView {
    function show(text, duration=-1, info="", is_error=true, open_notifications_modal=false) {
        model.insert(0, { text, duration, info, is_error, open_notifications_modal })
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
        Component.onCompleted: show(text, duration, info, is_error, open_notifications_modal)
    }

    model: ListModel { id: model }
}
