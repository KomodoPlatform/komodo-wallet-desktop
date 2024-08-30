import bignumberjs 1.0

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import QtQuick.Controls.Universal 2.15

import "../Constants" as Dex
import App 1.0
import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex

DexRectangle
{
    id: root
    radius: 10
    visible: enabled
    opacity: .9
    color: Dex.CurrentTheme.innerBackgroundColor
    property string ticker
    property string fullname
    property string amount
    property int padding: 0
    property alias middle_text: middle_line.text_value
    property alias bottom_text: bottom_line.text_value
    property bool is_left: false
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.leftMargin: 10
    Layout.rightMargin: 20

    DexLabel
    {
        anchors.bottom: parent.top
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        text: is_left ? "Outgoing" : "Incoming"
        font: Dex.DexTypo.italic12
        color: Dex.CurrentTheme.foregroundColor2
    }

    RowLayout
    {
        anchors.fill: parent
        anchors.centerIn: parent
        Layout.leftMargin: 20
        Layout.rightMargin: 20

        // Coin Icon
        Dex.Image
        {
            id: icon
            source: General.coinIcon(ticker)
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 20
            Layout.rightMargin: 10
            Layout.topMargin: 0
            Layout.bottomMargin: 0
        }

        //
        ColumnLayout
        {
            spacing: 2
            Layout.alignment: Qt.AlignVCenter

            DexLabel
            {
                Layout.preferredWidth: parent.width - 15
                text_value: `<font color="${Style.getCoinColor(ticker)}"><b>${ticker}</b></font>&nbsp;&nbsp;&nbsp;<font color="${Dex.CurrentTheme.foregroundColor}">${fullname}</font>`
                font: Dex.DexTypo.body2
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
            }

            DexLabel
            {
                id: middle_line
                property string coin_value: amount
                text_value: coin_value
                Layout.fillWidth: true
                elide: Text.ElideRight
                wrapMode: Label.NoWrap
                font: DexTypo.body3
                ToolTip.text: text_value
                privacy: true
            }

            DexLabel
            {
                id: bottom_line
                property string fiat_value: General.getFiatText(amount, ticker)
                text_value: fiat_value
                Layout.fillWidth: true
                elide: Text.ElideRight
                font: DexTypo.body3
                wrapMode: Label.NoWrap
                ToolTip.text: text_value
                privacy: true
            }
        }
    }
}