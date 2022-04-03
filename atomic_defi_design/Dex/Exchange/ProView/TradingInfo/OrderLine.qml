import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial

import QtGraphicalEffects 1.0

import App 1.0

import "../../../Components"
import Dex.Themes 1.0 as Dex

FloatingBackground
{
    property var            details
    property alias          clickable: mouse_area.enabled
    readonly property bool  is_placed_order: !details ? false : details.order_id !== ''

    height: 50

    color: mouse_area.containsMouse ? Dex.CurrentTheme.accentColor : Dex.CurrentTheme.floatingBackgroundColor
    radius: 0

    DefaultMouseArea
    {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: enabled
        onClicked:
        {
            order_modal.open()
            order_modal.item.details = details
        }
    }

    ColumnLayout
    {
        anchors.fill: parent
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 4
        spacing: 0

        Item
        {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            clip: true

            DefaultText
            {
                id: baseAmountLabel
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: 12
                text: !details ? "" : details.base_amount
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            DefaultText
            {
                anchors.left: baseAmountLabel.right
                anchors.leftMargin: 3
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: 12
                text: !details ? "" : "(%1 %2)".arg(details.base_amount_current_currency).arg(API.app.settings_pg.current_fiat_sign)
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Qaterial.ColorIcon
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                source: Qaterial.Icons.swapHorizontal
                color: Dex.CurrentTheme.foregroundColor
                iconSize: 18
            }

            DefaultText
            {
                anchors.right: relAmountInCurrCurrency.left
                anchors.rightMargin: 3
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: 12
                text: !details ? "" : details.rel_amount
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            DefaultText
            {
                id: relAmountInCurrCurrency

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: 12
                text: !details ? "" : "(%1 %2)".arg(details.rel_amount_current_currency).arg(API.app.settings_pg.current_fiat_sign)
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            DefaultImage
            {
                id: baseIcon

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                width: 15
                height: 15

                source: General.coinIcon(!details ? atomic_app_primary_coin : details.base_coin ?? atomic_app_primary_coin)
            }

            DefaultText
            {
                anchors.left: baseIcon.right
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter

                font.weight: Font.Bold
                font.pixelSize: 12
                text: !details ? "" : details.base_coin
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            DefaultText
            {
                visible: clickable

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: 11
                text_value: !details ? "" : details.date ?? ""
                elide: Text.ElideRight
                maximumLineCount: 1
                color: Dex.CurrentTheme.foregroundColor2
            }

            DefaultText
            {
                anchors.right: relCoin.left
                anchors.rightMargin: 2
                anchors.verticalCenter: parent.verticalCenter

                font.weight: Font.Bold
                font.pixelSize: 12
                text: !details ? "" : details.rel_coin
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            DefaultImage
            {
                id: relCoin

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 15
                height: 15

                source: General.coinIcon(!details ? atomic_app_primary_coin : details.rel_coin ?? atomic_app_secondary_coin)
            }
        }
    }

    // Separator
    HorizontalLine
    {
        width: parent.width
        height: 2
        anchors.bottom: parent.bottom
    }
}
