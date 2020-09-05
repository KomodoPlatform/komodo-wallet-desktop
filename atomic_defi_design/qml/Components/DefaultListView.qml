import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ListView {
    id: root

    property var onHitBottom: () => {}

    property bool scrollbar_visible: contentHeight > height
    readonly property double scrollbar_margin: scrollbar_visible ? 8 : 0
    ScrollBar.vertical: DefaultScrollBar {
        property double last_position: 0
        onPositionChanged: {
            const curr_pos = position + size

            if(last_position < 1.0 && curr_pos >= 1.0)
                onHitBottom()

            last_position = curr_pos
        }
    }

    implicitWidth: contentItem.childrenRect.width
    implicitHeight: contentItem.childrenRect.height

    clip: true
}
