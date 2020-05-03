import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ColumnLayout {
    property alias title: title.text
    property double bottomMargin: -1337

    // Title
    DefaultText {
        id: title
        font.pixelSize: Style.textSize2
    }

    HorizontalLine {
        Layout.fillWidth: true
        Layout.bottomMargin: bottomMargin === -1337 ? Style.modalTitleMargin : bottomMargin
    }
}
