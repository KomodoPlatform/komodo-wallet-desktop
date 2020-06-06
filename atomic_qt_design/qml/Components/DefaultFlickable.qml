import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

Flickable {
    id: flickable

    ScrollBar.vertical: DefaultScrollBar {
        policy: flickable.contentHeight > flickable.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }

    clip: true
}
