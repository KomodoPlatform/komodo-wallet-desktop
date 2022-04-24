//! Qt Imports
import QtQuick 2.15          //> Item
import QtQuick.Layouts 1.15  //> RowLayout
import QtQuick.Controls 2.15 //> ItemDelegate

// 3rdParty
import Qaterial 1.0 as Qaterial

import App 1.0

//! Project Imports
import "../../../Components" //> MultipageModal
import "../../../Constants" as Constants //> API
import Dex.Themes 1.0 as Dex

DexListView
{
    id: _listCoinView
    model: Constants.API.app.trading_pg.market_pairs_mdl.left_selection_box
    signal tickerSelected(var ticker)

    property real _rowWidth: width
    property real _rowHeight: 40
    property real _tokenColumnWidth: 120
    property real _balanceColumnWidth: 90
    property real _fiatColumnWidth: 90

    headerPositioning: ListView.OverlayHeader
    reuseItems: true
    cacheBuffer: 40
    clip: true

    header: DexRectangle
    {
        id: header_row
        width: _rowWidth
        height: _rowHeight
        z: 2
        color: Dex.CurrentTheme.floatingBackgroundColor

        RowLayout
        {
            id: columnsHeader
            anchors.margins: 5
            anchors.fill: parent
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            DexLabel             // "Token" Header
            {
                id: token_header
                property bool asc: true

                Layout.preferredWidth: _tokenColumnWidth
                horizontalAlignment: Text.AlignLeft

                text_value: qsTr("Token")
                font.family: Constants.Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold

                DexMouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true 
                    onClicked:
                    {
                        parent.asc = !parent.asc 
                        _listCoinView.model.sort_by_name(parent.asc)
                    }
                }
            }

            DexLabel             // "Balance" Header
            {
                id: balance_header
                property bool asc: true

                Layout.preferredWidth: _balanceColumnWidth
                horizontalAlignment: Text.AlignRight

                text_value: qsTr("Balance")
                font.family: Constants.Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold

                DexMouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true 
                    onClicked:
                    {
                        parent.asc = !parent.asc 
                        _listCoinView.model.sort_by_currency_balance(parent.asc)
                    }
                }
            }

            DexLabel             // Fiat Balance Header
            {
                id: fiat_balance_header
                property bool asc: true

                Layout.preferredWidth: _fiatColumnWidth
                horizontalAlignment: Text.AlignRight

                text_value: qsTr("Balance Fiat")
                font.family: Constants.Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold

                DexMouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true 
                    onClicked:
                    {
                        parent.asc = !parent.asc 
                        _listCoinView.model.sort_by_currency_balance(parent.asc)
                    }
                }
            }
        }
    }

    delegate: DexRectangle
    {
        id: coin_selection
        width: _listCoinView.width
        height: _rowHeight
        radius: 0
        border.width: 1

        colorAnimation: false
        color: mouse_area.containsMouse ? Dex.CurrentTheme.buttonColorHovered : 'transparent'

        DexMouseArea
        {
            id: mouse_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: tickerSelected(model.ticker)
        }

        RowLayout
        {
            id: columnsContent
            width: _listCoinView.width
            height: _rowHeight

            RowLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: _tokenColumnWidth
                spacing: 5

                DexImage
                {
                    id: _coinIcon
                    Layout.preferredHeight: 20
                    Layout.preferredWidth: 20
                    source: General.coinIcon(model.ticker)
                    Layout.alignment : Qt.AlignVCenter
                }

                DexLabel
                {
                    Layout.fillWidth: true
                    horizontalAlignment: Qt.AlignLeft
                    text_value: model.ticker
                }
            }

            DexLabel
            {
                Layout.fillHeight: true
                Layout.preferredWidth: _balanceColumnWidth
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap

                text_value: model.balance.replace(" ","")
            }

            DexLabel
            {
                Layout.fillHeight: true
                Layout.preferredWidth: _fiatColumnWidth
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap

                text_value: "%1".arg(General.getFiatText(model.balance, model.ticker, false))
            }
        }
    }

    DexLabel
    {
        anchors.centerIn: parent
        text: qsTr('No Selectable coin.')
        visible: parent.count === 0
    }
}
