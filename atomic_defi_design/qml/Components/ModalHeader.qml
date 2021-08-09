import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"
import App 1.0

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
