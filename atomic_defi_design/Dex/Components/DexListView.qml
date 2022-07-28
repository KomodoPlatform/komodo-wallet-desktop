import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Constants"
import App 1.0

ListView
{
    id: root

    property alias position: scrollVert.position
    property alias scrollVert: scrollVert
    property bool scrollbar_visible: contentItem.childrenRect.height > height
    property bool visibleBackground: false
    readonly property double scrollbar_margin: scrollbar_visible ? 8 : 0

    boundsBehavior: Flickable.StopAtBounds
    implicitHeight: contentItem.childrenRect.height
    implicitWidth: contentItem.childrenRect.width
    clip: true

    opacity: root.count === 0 ? 0 : enabled ? 1 : 0.2

    Behavior on opacity
    {
        SmoothedAnimation
        {
            duration: Style.animationDuration * 0.5
            velocity: -1
        }
    }

    ScrollBar.vertical: DefaultScrollBar
    {
        id: scrollVert
        visibleBackground: root.visibleBackground
    }
}
