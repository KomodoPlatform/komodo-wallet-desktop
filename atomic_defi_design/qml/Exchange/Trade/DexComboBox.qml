import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.0
import QtQuick.Controls.Universal 2.12

import "../../Components"
import "../../Constants"

DefaultComboBox {
    id: control

    mainBorderColor: Style.getCoinColor(ticker)

    // Each dropdown item
    delegate: ItemDelegate {
        Universal.accent: control.lineHoverColor
        width: control.width
        highlighted: control.highlightedIndex === index

        contentItem: RowLayout {
            DefaultImage {
                id: icon
                source: General.coinIcon(ticker)
                Layout.preferredWidth: 32
                Layout.preferredHeight: Layout.preferredWidth
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                ColumnLayout {
                    anchors.left: parent.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    DefaultText {
                        text_value: API.get().settings_pg.empty_string + (`<font color="${Style.getCoinColor(model.ticker)}"><b>${model.ticker}</b></font>&nbsp;&nbsp;&nbsp;<font color="${Style.colorText}">${model.name}</font>`)
                        color: Style.colorText
                        font.pixelSize: Style.textSizeSmall3
                    }

                    DefaultText {
                        text_value: API.get().settings_pg.empty_string + (General.formatCrypto("", model.balance, model.ticker,  model.main_currency_balance, API.get().settings_pg.current_currency))
                        color: Style.colorText2
                        font.pixelSize: Style.textSizeSmall2
                    }
                }
            }
        }
    }
}
