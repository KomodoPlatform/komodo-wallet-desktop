import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

Column {
    property alias parent_box: parentBox
    property alias group_title: parentBox.text
    property alias model: utxo_list.model

    ButtonGroup {
        id: childGroup
        exclusive: false
        checkState: parentBox.checkState
    }

    CheckBox {
        id: parentBox
        visible: utxo_list.model.length > 0
        checkState: childGroup.checkState
    }

    Repeater {
        id: utxo_list

        delegate: CheckBox {
            text: API.get().empty_string + "         " + (model.modelData.name + " (" + model.modelData.ticker + ")")
            leftPadding: indicator.width
            ButtonGroup.group: childGroup

            // Icon
            Image {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: parent.leftPadding + 28
                source: General.coinIcon(model.modelData.ticker)
                fillMode: Image.PreserveAspectFit
                width: Style.textSize2
                anchors.verticalCenter: parent.verticalCenter
            }

            checked: selected_to_enable[model.modelData.ticker] === true
            onCheckStateChanged: {
                markToEnable(model.modelData.ticker, checkState === Qt.Checked)
            }
        }
    }
}
