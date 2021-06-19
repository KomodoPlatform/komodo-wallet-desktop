//! Qt Imports
import QtQuick 2.15          //> Item
import QtQuick.Layouts 1.15  //> RowLayout
import QtQuick.Controls 2.15 //> ItemDelegate

// 3rdParty
import Qaterial 1.0 as Qaterial

//! Project Imports
import "../../../Components" //> BasicModal
import "../../../Constants"  //> API



DefaultListView
{
    id: _listCoinView
    property var tradeCard
    property string selectedTicker
    property bool best: true
    property string currentLeftToken // The token we wanna sell

    property int    _rowWidth: width - 20
    property int    _rowHeight: 50
    property int    _tokenColumnSize: 160
    property int    _balanceSize: 120
    property int    _fiatBalanceSize: 100
    property int    _fiatVolumeColumnSize: 50
    property int    _cexRateColumnSize: 50
    model: API.app.trading_pg.market_pairs_mdl.left_selection_box
    //snapMode: ListView.SnapToItem
    headerPositioning: ListView.OverlayHeader
    reuseItems: true
    cacheBuffer: 40
    onVisibleChanged: {
        currentLeftToken = _tradeCard.selectedTicker
    }
    header: DexRectangle // Best orders list header
    {
        width: _rowWidth
        height: _rowHeight
        border.color: 'transparent'
        color: theme.dexBoxBackgroundColor
        z: 2
        radius: 0
        RowLayout                   // Order Columns Name
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.fill: parent
            spacing: 2
            DexLabel             // "Token" Header
            {
            	property bool asc: true
                Layout.preferredWidth: _tokenColumnSize
                text: qsTr("Token")
                font.family: Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold
                color: children[1].containsMouse? theme.accentColor : theme.foregroundColor 
                DexMouseArea {
                	anchors.fill: parent
                	hoverEnabled: true 
                	onClicked: {
                		parent.asc = !parent.asc 
                		_listCoinView.model.sort_by_name(parent.asc)
                	}
                }
            }
            DexLabel             // "Available Quantity" Header
            {
            	property bool asc: true
                Layout.fillWidth: true
                text: qsTr("Balance")
                font.family: Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold
                color: children[1].containsMouse? theme.accentColor : theme.foregroundColor 
                DexMouseArea {
                	anchors.fill: parent
                	hoverEnabled: true 
                	onClicked: {
                		parent.asc = !parent.asc 
                		_listCoinView.model.sort_by_currency_balance(parent.asc)
                	}
                }
            }
            DexLabel             // "Available Quantity (in BASE)" header
            {
            	property bool asc: true
                text: qsTr("Balance Fiat")
                font.family: Style.font_family
                font.bold: true
                font.pixelSize: 12
                font.weight: Font.Bold
                color: children[1].containsMouse? theme.accentColor : theme.foregroundColor 
                DexMouseArea {
                	anchors.fill: parent
                	hoverEnabled: true 
                	onClicked: {
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
        RowLayout {
        	anchors.fill: parent
        	spacing: 2
        	Item {
        		Layout.preferredWidth: _tokenColumnSize
        		height: 40
        		Row {
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
        		Qaterial.DebugRectangle {
                	anchors.fill: parent
                	visible: false
                }
        	}
        	Item {
        		Layout.fillWidth: true
        		height: 40
        		DexLabel
	            {
	                anchors.verticalCenter: parent.verticalCenter
	                text: model.balance.replace(" ","")
	                horizontalAlignment: Label.AlignLeft
	                
	            }
	            Qaterial.DebugRectangle {
                	anchors.fill: parent
                	visible: false
                }
        	}
            DexLabel
            {
                Layout.alignment: Qt.AlignVCenter
                text: "%1".arg(General.getFiatText(model.balance, model.ticker, false))
                Qaterial.DebugRectangle {
                	anchors.fill: parent
                	visible: false
                }
            }
        }
        

        MouseArea
        {
            anchors.fill: parent
            onClicked:
            {
                _listCoinView.selectedTicker = model.ticker
                
            }
        }
    }
    DexLabel {
        anchors.centerIn: parent
        text: qsTr('No Selectable coin.')
        visible: parent.count==0
    }
}
