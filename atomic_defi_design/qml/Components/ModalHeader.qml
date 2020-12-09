import QtQuick.Layouts 1.15
import "../Constants/Style.qml" as Style

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
