import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ListView {
    id: list

    ScrollBar.vertical: DefaultScrollBar {
        policy: list.contentHeight > list.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }

    implicitWidth: contentItem.childrenRect.width
    implicitHeight: contentItem.childrenRect.height

    clip: true
}
