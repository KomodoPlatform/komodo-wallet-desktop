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

    height: 30

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

    RowLayout
    {
        anchors.fill: parent

        DefaultText
        {
            visible: clickable
            Layout.preferredWidth: (parent.width / 100) * 18
            font.pixelSize: 12
            text_value: !details ? "" : details.date ?? ""
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        DefaultImage
        {
            id: base_icon
            source: General.coinIcon(!details ? atomic_app_primary_coin :
                details.base_coin ?? atomic_app_primary_coin)
            Layout.preferredWidth: 15
            Layout.preferredHeight: width
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 5
        }

        Row
        {
            Layout.preferredWidth: (parent.width / 100) * 30
            spacing: 6
            DefaultText
            {
                font.weight: Font.Bold
                font.pixelSize: 12
                text: !details ? "" : details.base_coin
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
                width: implicitWidth > (parent.width / 100) * 30 ? (parent.width / 100) * 30 : implicitWidth
            }
            DefaultText
            {
                font.pixelSize: 12
                text: !details ? "" : details.base_amount
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
                width: implicitWidth > (parent.width / 100) * 40 ? (parent.width / 100) * 40 : implicitWidth
            }
            DefaultText
            {
                font.pixelSize: 12
                text: !details ? "" : "(%1 %2)".arg(details.base_amount_current_currency).arg(API.app.settings_pg.current_fiat_sign)
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
                width: implicitWidth > (parent.width / 100) * 30 ? (parent.width / 100) * 30 : implicitWidth
            }
        }

        Item
        {
            Layout.fillWidth: true
            SwapIcon
            {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: details.order_status === "failed" ? Dex.CurrentTheme.noColor : Dex.CurrentTheme.foregroundColor
                top_arrow_ticker: !details ? atomic_app_primary_coin : details.base_coin ?? ""
                bottom_arrow_ticker: !details ? atomic_app_primary_coin : details.rel_coin ?? ""
            }
        }

        Row
        {
            layoutDirection: Qt.RightToLeft
            Layout.preferredWidth: (parent.width / 100) * 30
            spacing: 6
            DefaultText
            {
                font.pixelSize: 12
                text: !details ? "" : "(%1 %2)".arg(details.rel_amount_current_currency).arg(API.app.settings_pg.current_fiat_sign)
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
                width: implicitWidth > (parent.width / 100) * 30 ? (parent.width / 100) * 30 : implicitWidth
            }
            DefaultText
            {
                font.pixelSize: 12
                text: !details ? "" : details.rel_amount
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
                width: implicitWidth > (parent.width / 100) * 40 ? (parent.width / 100) * 40 : implicitWidth
            }
            DefaultText
            {
                font.weight: Font.Bold
                font.pixelSize: 12
                text: !details ? "" : details.rel_coin
                privacy: is_placed_order
                elide: Text.ElideRight
                maximumLineCount: 1
                width: implicitWidth > (parent.width / 100) * 30 ? (parent.width / 100) * 30 : implicitWidth
            }
        }

        DefaultImage
        {
            id: rel_icon
            source: General.coinIcon(!details ? atomic_app_primary_coin :
                details.rel_coin ?? atomic_app_secondary_coin)
            Layout.preferredWidth: 15
            Layout.preferredHeight: 15
            Layout.alignment: Qt.AlignVCenter
        }

        DefaultText
        {
            font.pixelSize: 12
            visible: !details || details.recoverable === undefined ? false :
                details.recoverable && details.order_status !== "refunding"
            Layout.preferredWidth: (parent.width / 100) * 2
            Layout.preferredHeight: width
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignHCenter
            text_value: Style.warningCharacter
            color: Style.colorYellow

            DefaultTooltip
            {
                contentItem: DefaultText
                {
                    text_value: qsTr("Funds are recoverable")
                    font.pixelSize: Style.textSizeSmall4
                }

                visible: (parent.visible && mouse_area.containsMouse) ?? false
            }
        }

        MouseArea
        {
            id: cancel_button_text

            visible: !is_history

            Layout.preferredWidth: (parent.width / 100) * 2
            Layout.preferredHeight: width

            onClicked: if (details) cancelOrder(details.order_id)

            Behavior on scale
            {
                NumberAnimation
                {
                    duration: 200
                }
            }
            Qaterial.ColorIcon
            {
                anchors.fill: parent
                iconSize: 14
                color: Dex.CurrentTheme.noColor
                source: Qaterial.Icons.close
            }
        }
    }

    // Separator
    HorizontalLine
    {
        width: parent.width
        anchors.bottom: parent.bottom
    }
}
