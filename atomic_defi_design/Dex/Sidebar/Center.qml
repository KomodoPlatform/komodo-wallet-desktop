import QtQuick 2.12
import QtQuick.Layouts 1.2

import App 1.0
import "../Components"
import "../Constants"
import Dex.Themes 1.0 as Dex

Item
{
    property alias spacing: _columnLayout.spacing

    signal lineSelected(var lineType)

    height: lineHeight * 5

    // Selection List
    ColumnLayout
    {
        id: _columnLayout
        anchors.fill: parent
        FigurativeLine
        {
            id: _portfolioLine

            Layout.fillWidth: true
            type: Main.LineType.Portfolio
            label.text: isExpanded ? qsTr("Portfolio") : ""
            icon.source: General.image_path + "menu-assets-portfolio.svg"
            onClicked: lineSelected(type)

            DexTooltip
            {
                visible: !isExpanded && parent.mouseArea.containsMouse
                text: qsTr("Portfolio")
            }
        }

        FigurativeLine
        {
            id: _walletLine

            Layout.fillWidth: true
            type: Main.LineType.Wallet
            label.text: isExpanded ? qsTr("Wallet") : ""
            icon.source: General.image_path + "menu-assets-white.svg"
            onClicked: lineSelected(type)

            DexTooltip
            {
                visible: !isExpanded && parent.mouseArea.containsMouse
                text: qsTr("Wallet")
            }
        }

        FigurativeLine
        {
            id: _dexLine

            Layout.fillWidth: true
            type: Main.LineType.DEX
            label.text: isExpanded ? qsTr("DEX") : ""
            icon.source: General.image_path + "menu-exchange-white.svg"
            onClicked: lineSelected(type)

            DexTooltip
            {
                visible: !isExpanded && parent.mouseArea.containsMouse
                text: qsTr("DEX")
            }
        }

        FigurativeLine
        {
            id: _addressBookLine

            Layout.fillWidth: true
            type: Main.LineType.Addressbook
            label.text: isExpanded ? qsTr("Address Book") : ""
            icon.source: General.image_path + "menu-news-white.svg"
            onClicked: lineSelected(type)

            DefaultTooltip
            {
                visible: !isExpanded && parent.mouseArea.containsMouse
                text: qsTr("Address Book")
            }
        }

        FigurativeLine
        {
            label.enabled: false
            Layout.fillWidth: true
            label.text: isExpanded ? qsTr("Fiat") : ""
            icon.source: General.image_path + "bill.svg"

            DefaultTooltip
            {
                visible: parent.mouseArea.containsMouse
                text: isExpanded ? qsTr("Coming soon !") : qsTr("Fiat")
            }
        }
    }
}
