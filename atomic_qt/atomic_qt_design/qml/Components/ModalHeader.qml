import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

ColumnLayout {
    property alias title: title.text

    // Title
    DefaultText {
        id: title
        font.pointSize: Style.textSize2
    }

    HorizontalLine {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.modalTitleMargin
    }
}
