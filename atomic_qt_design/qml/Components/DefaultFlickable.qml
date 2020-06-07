import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

Flickable {
    id: root

    property bool scrollbar_visible: contentHeight > height
    ScrollBar.vertical: DefaultScrollBar { }

    clip: true
}
