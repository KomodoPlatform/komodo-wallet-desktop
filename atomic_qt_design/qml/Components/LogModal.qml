import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

DefaultModal {
    property alias title: text_area.title
    property alias field: text_area.field


    id: root

    padding: 50

    width: 900
    height: Math.min(text_area.height + padding*2, 700)

    DefaultFlickable {
        anchors.fill: parent
        contentWidth: text_area.width
        contentHeight: text_area.height

        TextAreaWithTitle {
            id: text_area
            width: root.width - root.padding*2
            field.readOnly: true
            copyable: true
            remove_newline: false
        }
    }
}
