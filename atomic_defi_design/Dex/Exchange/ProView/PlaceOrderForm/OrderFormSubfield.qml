import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "../../../Components"
import App 1.0
import Dex.Themes 1.0 as Dex

RowLayout
{
    id: control
    property alias  fiat_value: fiat_label.text_value
    property alias  left_label: _left_label.text
    property alias  middle_label: _middle_label.text
    property alias  right_label: _right_label.text
    property alias  market: _market
    property alias  increase: _increase
    property alias  reduce: _reduce
    property int    pixel_size: 12
    property int    btn_width: 33
    spacing: 2
    height: 20
    width: parent.width

    Item
    {
        width: btn_width
        height: parent.height

        // Background when market mode is different
        DefaultRectangle
        {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            color: Dex.CurrentTheme.tradeMarketModeSelectorNotSelectedBackgroundColor
        }

        DefaultText
        {
            id: _left_label
            anchors.centerIn: parent
            font.pixelSize: pixel_size
            color: Dex.CurrentTheme.foregroundColor2
            text: "-1%"
        }

        DefaultMouseArea
        {
            id: _reduce
            anchors.fill: parent
        }
    }

    Item
    {

        width: btn_width
        height: parent.height

        // Background when market mode is different
        DefaultRectangle
        {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            color: Dex.CurrentTheme.tradeMarketModeSelectorNotSelectedBackgroundColor
        }

        DefaultText
        {
            id: _middle_label
            anchors.centerIn: parent
            font.pixelSize: pixel_size
            color: Dex.CurrentTheme.foregroundColor2
            text: "0%"
        }

        DefaultMouseArea
        {
            id: _market
            anchors.fill: parent
        }
    }
    Item
    {

        width: btn_width
        height: parent.height

        // Background when market mode is different
        DefaultRectangle
        {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            color: Dex.CurrentTheme.tradeMarketModeSelectorNotSelectedBackgroundColor
        }

        DefaultText
        {
            id: _right_label
            anchors.centerIn: parent
            font.pixelSize: pixel_size
            color: Dex.CurrentTheme.foregroundColor2
            text: "+1%"
        }

        DefaultMouseArea
        {
            id: _increase
            anchors.fill: parent
        }
    }

    Item { Layout.fillWidth: true }

    DefaultText
    {
        id: fiat_label
        text_value: _fiat_text
        font.pixelSize: pixel_size
        color: Dex.CurrentTheme.foregroundColor2

        CexInfoTrigger {}
    }
}