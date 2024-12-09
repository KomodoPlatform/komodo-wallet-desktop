import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Components"
import "../../Constants"

DexLabel {
    property var trade_info
    property string base

    visible: trade_info !== undefined

    text_value: General.cex_icon

    DefaultMouseArea {
        id: mouse_area
        anchors.fill: parent
        enabled: parent.visible
        hoverEnabled: true
    }

    DefaultTooltip {
        visible: mouse_area.containsMouse

        contentItem: ColumnLayout {
            DexLabel {
                id: tx_fee_text
                text_value: General.txFeeText(trade_info, base, false)
                font.pixelSize: Style.textSizeSmall4
            }
            DexLabel {
                text_value: General.tradingFeeText(trade_info, base, false)
                font.pixelSize: tx_fee_text.font.pixelSize
            }
        }
    }
}
