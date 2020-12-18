import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import AtomicDEX.CoinType 1.0

import "../Components"
import "../Constants"

Column {
    id: root

    property alias parent_box: parentBox
    property alias group_title: parentBox.text
    property var model

    ButtonGroup {
        id: childGroup
        exclusive: false
        checkState: parentBox.checkState
    }

    DefaultCheckBox {
        id: parentBox
        visible: repeater.count > 0
        checkState: childGroup.checkState
    }

    Repeater {
        id: repeater
        model: root.model

        DefaultCheckBox {
            text: "         " + model.name + " (" + model.ticker + ")"
            leftPadding: indicator.width
            ButtonGroup.group: childGroup

            onCheckStateChanged: {
                if (checkable) {
                    model.checked = checked
                }
            }

            /* handles special case where the check box is unchecked by the search bar filtering even
               when the coin is still considered as checked */
            Component.onCompleted: checked = model.checked

            // Icon
            DefaultImage {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: parent.leftPadding + 28
                source: General.coinIcon(model.ticker)
                width: Style.textSize2
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
