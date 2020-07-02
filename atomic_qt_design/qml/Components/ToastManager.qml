// This is a modified version of QML Toast Implementation of jonmcclung
// https://gist.github.com/jonmcclung/bae669101d17b103e94790341301c129

import QtQuick 2.12

ListView {
    function show(text, duration=-1, info="", is_error=true) {
        model.insert(0, { text, duration, info, is_error })
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
        Component.onCompleted: show(text, duration, info, is_error)
    }

    model: ListModel { id: model }
}
