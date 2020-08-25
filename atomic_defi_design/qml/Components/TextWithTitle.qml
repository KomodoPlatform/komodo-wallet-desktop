import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ColumnLayout {
    property alias title: title.text
    property alias text: text.text_value
    property alias value_color: text.color
    property alias privacy: text.privacy

    DefaultText {
        id: title
        Layout.fillWidth: true
    }

    DefaultText {
        id: text
        Layout.fillWidth: true
        color: Style.modalValueColor
    }
}
