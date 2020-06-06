import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

Flickable {
    id: root

    ScrollBar.vertical: DefaultScrollBar {
        anchors.right: root.right
        anchors.rightMargin: Style.scrollbarOffset
        policy: root.contentHeight > root.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }

    clip: true
}
