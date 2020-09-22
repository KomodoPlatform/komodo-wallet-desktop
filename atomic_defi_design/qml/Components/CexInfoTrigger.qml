import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

DefaultMouseArea {
    anchors.fill: parent
    onClicked: cex_rates_modal.open()
}
