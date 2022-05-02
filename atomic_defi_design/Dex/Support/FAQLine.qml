import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"
import App 1.0

TextWithTitle {
    expandable: true
    Layout.fillWidth: true
    Layout.rightMargin: 10
    text_font.pixelSize: 14
    title_font.pixelSize: 18
}
