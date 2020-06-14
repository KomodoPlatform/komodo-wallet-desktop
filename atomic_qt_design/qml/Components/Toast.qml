// This is a modified version of QML Toast Implementation of jonmcclung
// https://gist.github.com/jonmcclung/bae669101d17b103e94790341301c129

import QtQuick 2.12
import "../Constants"

Rectangle {
    function show(text, duration, info, is_error) {
        title = text
        details = info
        isError = is_error

        if (duration === -1) time = defaultTime
        else time = Math.max(duration, 2 * fadeTime)

        animation.start();
    }

    property bool selfDestroying: false

    id: root

    readonly property real defaultTime: 2000
    property real time: defaultTime
    readonly property real fadeTime: 300

    property real margin: 10

    anchors {
        horizontalCenter: parent.horizontalCenter
        margins: margin
    }

    width: message.width + margin
    height: message.height + margin

    radius: margin / 3

    opacity: 0
    color: isError ? Style.colorRed : Style.colorTheme1

    DefaultText {
        id: message
        color: "white"
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        anchors {
            top: parent.top
            left: parent.left
            margins: margin / 2
        }
        font.pixelSize: Style.textSizeSmall2
        text: title + (details !== undefined && details !== "" ? (" - " + qsTr("Click here to see the details")) : "")
    }

    SequentialAnimation on opacity {
        id: animation
        running: false

        NumberAnimation {
            to: .7
            duration: fadeTime
        }

        PauseAnimation {
            duration: time - 2 * fadeTime
        }

        NumberAnimation {
            to: 0
            duration: fadeTime
        }

        onRunningChanged: {
            if (!running && selfDestroying) root.destroy()
        }
    }

    property string title: ""
    property string details: ""
    property bool isError: false

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if(details !== "") {
                showError(title, details)
                root.visible = false
            }
        }
    }
}
