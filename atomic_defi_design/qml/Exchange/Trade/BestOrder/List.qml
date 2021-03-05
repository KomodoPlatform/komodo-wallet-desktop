import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial
import "../../../Constants/"


Item {
    id: _control
    Header {
    }

    ListView {
        id: list
        anchors.topMargin: 40
        anchors.fill: parent
        model: 40
        clip: true
        snapMode: ListView.SnapToItem
        headerPositioning: ListView.OverlayHeader
        delegate: ListDelegate  {}
    }
}
