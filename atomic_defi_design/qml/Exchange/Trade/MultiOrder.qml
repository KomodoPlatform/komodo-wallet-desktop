import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Components"
import "../../Constants"

InnerBackground {
    DefaultListView {
        id: list
        anchors.fill: parent

        model: API.app.trading_pg.market_pairs_mdl.left_selection_box

        delegate: Item {
            width: list.width
            height: 60

            DexComboBoxLine {
                anchors.fill: parent
                details: model
                padding: 10
            }

            DefaultSwitch {
                anchors.rightMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }

            HorizontalLine {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
    }
}
