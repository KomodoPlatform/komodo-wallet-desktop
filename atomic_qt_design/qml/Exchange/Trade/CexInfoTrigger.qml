import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

MouseArea {
    anchors.fill: parent
    onClicked: cex_rates_modal.open()
}
