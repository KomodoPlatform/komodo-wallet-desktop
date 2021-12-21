//! Qt Imports
import QtQuick 2.15          //> Item
import QtQuick.Layouts 1.15  //> RowLayout
import QtQuick.Controls 2.15 //> ItemDelegate

// 3rdParty
import Qaterial 1.0 as Qaterial

import App 1.0

//! Project Imports
import "../../../Components" //> BasicModal
import "../../../Constants" as Constants //> API
import Dex.Themes 1.0 as Dex

DefaultListView
{
    id: _listCoinView

    property int    _rowWidth: width - 20
    property int    _rowHeight: 50
    property int    _tokenColumnSize: 160

    signal          tickerSelected(var ticker)

    model: Constants.API.app.trading_pg.market_pairs_mdl.left_selection_box
    headerPositioning: ListView.OverlayHeader
    reuseItems: true
    cacheBuffer: 40
    clip: true

    header: DefaultRectangle
    {
        width: _rowWidth
        height: _rowHeight
        z: 2
        color: Dex.CurrentTheme.floatingBackgroundColor

        RowLayout                   // Coins Columns Name
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.fill: parent
            spacing: 2
            DefaultText             // "Token" Header
            {
            	property bool asc: true

                Layout.preferredWidth: _tokenColumnSize
                text: qsTr("Token")
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
            DefaultText             // "Balance" Header
            {
            	property bool asc: true

                Layout.fillWidth: true
                text: qsTr("Balance")
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
            DefaultText             // Fiat Balance Header
            {
            	property bool asc: true

                text: qsTr("Balance Fiat")
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

    delegate: ItemDelegate
    {
        width: _listCoinView._rowWidth
        height: 40
        RowLayout
        {
        	anchors.fill: parent
        	spacing: 2
            Item
            {
        		Layout.preferredWidth: _tokenColumnSize
        		height: 40
                Row
                {
        			anchors.verticalCenter: parent.verticalCenter
        			spacing: 10
        			DefaultImage
			        {
			            id: _coinIcon
			            width: 20
				        height: 20
			            source: General.coinIcon(model.ticker)
			            anchors.verticalCenter: parent.verticalCenterv
			        }
			        DefaultText
		            {
		                anchors.verticalCenter: parent.verticalCenter
		                text: model.ticker
		                
		            }
        		}
                Qaterial.DebugRectangle
                {
                	anchors.fill: parent
                	visible: false
                }
        	}
            Item
            {
        		Layout.fillWidth: true
        		height: 40
        		DexLabel
	            {
	                anchors.verticalCenter: parent.verticalCenter
	                text: model.balance.replace(" ","")
	                horizontalAlignment: Label.AlignLeft
	                
	            }
                Qaterial.DebugRectangle
                {
                	anchors.fill: parent
                	visible: false
                }
        	}
            DexLabel
            {
                Layout.alignment: Qt.AlignVCenter
                text: "%1".arg(General.getFiatText(model.balance, model.ticker, false))
                Qaterial.DebugRectangle
                {
                	anchors.fill: parent
                	visible: false
                }
            }
        }
        
        MouseArea
        {
            anchors.fill: parent
            onClicked: tickerSelected(model.ticker)
        }
    }

    DexLabel
    {
        anchors.centerIn: parent
        text: qsTr('No Selectable coin.')
        visible: parent.count === 0
    }
}
