import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ColumnLayout {
    property alias title: title.text

    // Title
    DefaultText {
        id: title
        font.pixelSize: Style.textSize2
    }

    HorizontalLine {
        Layout.fillWidth: true
    }
}
