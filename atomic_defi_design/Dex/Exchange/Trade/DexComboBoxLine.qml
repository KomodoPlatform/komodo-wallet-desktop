import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import QtQuick.Controls.Universal 2.15

import "../../Components"
import App 1.0
import Dex.Themes 1.0 as Dex

RowLayout
{
    id: root

    property int padding: 0
    property var details
    property color color: !details ? "white" : Style.getCoinColor(details.ticker)
    property alias bottom_text: bottom_line.text_value

    Behavior on color { ColorAnimation { duration: Style.animationDuration } }

    DefaultImage
    {
        id: icon
        source: General.coinIcon(ticker)
        Layout.preferredWidth: 32
        Layout.preferredHeight: 45
        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
        Layout.leftMargin: padding
        Layout.topMargin: Layout.leftMargin
        Layout.bottomMargin: Layout.leftMargin

        ColumnLayout
        {
            anchors.left: parent.right
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: root.width - 40

            DefaultText
            {
                Layout.preferredWidth: parent.width - 15

                text_value: !details ? "" :
                            `<font color="${root.color}"><b>${details.ticker}</b></font>&nbsp;&nbsp;&nbsp;<font color="${Dex.CurrentTheme.foregroundColor}">${details.name}</font>`
                color: Style.colorText
                font.pixelSize: Style.textSizeSmall3
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
            }

            DefaultText
            {
                id: bottom_line

                property string real_value: !details ? "" :
                            details.balance + "  (" + General.formatFiat("", details.main_currency_balance, API.app.settings_pg.current_fiat_sign) + ")"

                text: real_value
                Layout.fillWidth: true
                elide: Text.ElideRight
                color: DexTheme.foregroundColor
                font: DexTypo.body2
                wrapMode: Label.NoWrap
                ToolTip.text: real_value
                Component.onCompleted: font.pixelSize = 11.5
            }
        }
    }
}
