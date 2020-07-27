import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ListView {
    id: root

    readonly property bool scrollbar_visible: contentHeight > height
    readonly property double scrollbar_margin: scrollbar_visible ? 8 : 0
    ScrollBar.vertical: DefaultScrollBar { }

    implicitWidth: contentItem.childrenRect.width
    implicitHeight: contentItem.childrenRect.height

    clip: true
}
