import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants" as Constants
import App 1.0
import Dex.Themes 1.0 as Dex

// Coins bar at left side
Item
{
    id: root

    function reset() { resetted() }

    signal resetted()

    Layout.alignment: Qt.AlignLeft
    Layout.fillHeight: true
    Layout.preferredWidth: 175

    // Background
    DefaultRectangle
    {
        id: background
        anchors.right: parent.right
        width: parent.width

        height: parent.height 

        // Panel contents
        Item
        {
            id: coins_bar
            width: 175
            height: parent.height
            anchors.right: parent.right

            ColumnLayout
            {
                anchors.fill: parent
                anchors.topMargin: 30
                anchors.bottomMargin: 30
                anchors.leftMargin: 10
                anchors.rightMargin: 20
                spacing: 40

                InnerBackground
                {
                    id: search_row_bg
                    Layout.preferredWidth: 145
                    radius: 14
                    Layout.alignment: Qt.AlignHCenter
                    color: DexTheme.contentColorTop
                    shadowOff: true

                    content: RowLayout
                    {
                        id: search_row

                        // Search icon
                        Item
                        {
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: search_button.width
                            Layout.rightMargin: -Layout.leftMargin
                            width: search_button.width
                            height: search_button.height

                            DefaultImage
                            {
                                id: search_button

                                source: General.image_path + "exchange-search.svg"

                                width: input_coin_filter.font.pixelSize; height: width

                                visible: false
                            }

                            DefaultColorOverlay
                            {
                                id: search_button_overlay

                                anchors.fill: search_button
                                source: search_button
                                color: Dex.CurrentTheme.foregroundColor
                            }
                        }

                        // Search input
                        DefaultTextField
                        {
                            id: input_coin_filter

                            placeholderText: qsTr("Search coin")

                            onTextChanged: portfolio_coins.setFilterFixedString(text)
                            font.pixelSize: Constants.Style.textSizeSmall3

                            background: null

                            Layout.fillWidth: true

                            Component.onDestruction: portfolio_coins.setFilterFixedString("")

                            Connections
                            {
                                target: root

                                function onResetted()
                                {
                                    if (input_coin_filter.text === "") resetCoinFilter()
                                    else input_coin_filter.text = ""
                                }
                            }
                        }
                    }
                }

                // Coins list
                InnerBackground {
                    id: list_bg
                    Layout.preferredWidth: 145
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    color: 'transparent'
                    shadowOff: true
                    content: DexListView {
                        id: list
                        height: list_bg.height
                        model: portfolio_coins
                        topMargin: 5
                        bottomMargin: 5
                        scrollbar_visible: false
                        DexRectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width + 4
                            height: 30
                            radius: 8
                            opacity: .5
                            visible: list.position < (.98 - list.scrollVert.visualSize) ? true : false
                            Qaterial.Icon
                            {
                                anchors.centerIn: parent
                                color: Dex.CurrentTheme.foregroundColor
                                icon: Qaterial.Icons.arrowDownCircleOutline
                            }
                        }

                        DexRectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width + 4
                            height: 30
                            radius: 8
                            opacity: .5
                            visible: list.position > 0 ? true : false
                            Qaterial.Icon {
                                anchors.centerIn: parent
                                color: DexTheme.foregroundColor
                                icon: Qaterial.Icons.arrowUpCircleOutline
                            }
                        }

                        reuseItems: true

                        delegate: SidebarItemDelegate { }
                    }
                }

                DexAppButton {
                    id: add_coin_button
                    onClicked: enable_coin_modal.open()
                    Layout.alignment:  Qt.AlignHCenter
                    Layout.preferredWidth: 140
                    radius: 18
                    spacing: 2
                    font: Qt.font({
                        pixelSize: 9 * DexTypo.fontDensity,
                        letterSpacing: 1.25,
                        capitalization: Font.AllUppercase,
                        family: DexTypo.fontFamily,
                        weight: Font.Normal
                    })
                    text: qsTr("Add asset")
                    iconSource: Qaterial.Icons.plus
                    leftPadding: 3
                    rightPadding: 3

                }
            }

            VerticalLine {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 1
                opacity: .3
                anchors.topMargin: anchors.bottomMargin
                color: DexTheme.walletSidebarLeftBorderColor
            }

            
        }
    }

     DexRectangle {
        anchors.right: parent.right
        height: parent.height
        width: 1
        color: DexTheme.sideBarRightBorderColor
        border.width: 0
    }
}
