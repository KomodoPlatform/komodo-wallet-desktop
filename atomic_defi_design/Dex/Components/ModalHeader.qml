import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"
import App 1.0

ColumnLayout {
    property alias title: title.text

    // Title
    DexLabel {
        id: title
        font: DexTypo.head6
    }

    Item {
        Layout.fillWidth: true
    }
}
