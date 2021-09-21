import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15

import Qaterial 1.0 as Qaterial

import "../Constants"
as Constants
import App 1.0

ComboBox {
    id: control
    property
    var dropdownLineText: m => textRole === "" ?
        m.modelData :
        !m.modelData ? m[textRole] : m.modelData[textRole]
    property string currentTicker: "All"
    delegate: ItemDelegate 
    {
        width: control.width + 50
        highlighted: control.highlightedIndex === index
        contentItem: DefaultText 
        {
            text_value: control.currentTicker
            color: DexTheme.foregroundColor
        }
    }

    indicator: Qaterial.Icon {
        x: control.mirrored ? control.padding : control.width - width - control.padding - 4
        y: control.topPadding + (control.availableHeight - height) / 2
        color: control.contentItem.color
        icon: Qaterial.Icons.chevronDown
    }

    contentItem: DexLabel 
    {
        leftPadding: 10
        verticalAlignment: Text.AlignVCenter

        width: _background.width - leftPadding
        height: _background.height

        color: DexTheme.foregroundColor
        text: control.currentTicker
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
    }

    background: DexRectangle {
        id: _background

        //implicitWidth: 120

        implicitHeight: 40
        colorAnimation: false
        color: !control.enabled ? DexTheme.backgroundDarkColor0 : control.hovered ? DexTheme.backgroundDarkColor0 : DexTheme.surfaceColor
        radius: 8
    }

    popup: Popup {
        id: comboPopup
        readonly property double max_height: 350
        y: control.height - 1
        width: control.width + 50
        height: Math.min(contentItem.implicitHeight, popup.max_height)
        padding: 1

        contentItem: ColumnLayout {
            anchors.rightMargin: 5

            DefaultTextField {
                id: input_coin_filter
                placeholderText: qsTr("Search")

                background: Item {
                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: -5
                        anchors.rightMargin: -1
                        border.color: "transparent"
                        color: DexTheme.backgroundColor
                    }
                }

                onTextChanged: {
                    control.model.setFilterFixedString(text)
                }

                function reset() {
                    text = ""
                }

                Connections {
                    target: popup
                    function onOpened() {
                        input_coin_filter.reset()
                        input_coin_filter.forceActiveFocus()
                    }

                    function onClosed() {
                        input_coin_filter.reset()
                    }
                }



                font.pixelSize: 16
                Layout.fillWidth: true
                Layout.leftMargin: 0
                Layout.preferredHeight: 40
                Layout.rightMargin: 2 //Layout.leftMargin
                Layout.topMargin: Layout.leftMargin
                Keys.onDownPressed: {
                    control.incrementCurrentIndex()
                }
                Keys.onUpPressed: {
                    control.decrementCurrentIndex()
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return) {
                        if (control.count > 0) {
                            control.currentIndex = 0 //control.highlightedIndex
                            control.currentTicker = control.currentText
                        }
                        popup.close()
                        event.accepted = true
                    }
                }
            }
            Item {
                Layout.maximumHeight: popup.max_height - 100
                Layout.fillWidth: true
                implicitHeight: popup_list_view.contentHeight + 5
                DexListView {
                    id: popup_list_view
                    model: control.popup.visible ? control.model : null
                    currentIndex: control.highlightedIndex
                    anchors.fill: parent
                    anchors.bottomMargin: 10
                    anchors.rightMargin: 2
                    highlight: DexRectangle {
                        radius: 0
                    }
                    clip: true
                    delegate: ItemDelegate {
                        width: control.width + 50
                        highlighted: control.highlightedIndex === index
                        //foregroundColor: DexTheme.foregroundColor
                        contentItem: DefaultText {
                            text_value: "<b><font color='" + DexTheme.getCoinColor(ticker) + "'>" + ticker + "</font></b>" + "    %1".arg(General.coinName(ticker)) 
                            
                        }

                        background: DexRectangle {
                            colorAnimation: false
                            radius: 0
                            color: popup_list_view.currentIndex === index ? DexTheme.buttonColorHovered : DexTheme.comboBoxBackgroundColor
                            border.color: 'transparent'
                        }

                        onClicked: {
                            control.currentTicker = ticker
                            popup.close()
                        }
                    }

                    DexMouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                    }
                }
            }

        }

        background: DexRectangle {
            y: -5
            radius: 0
            colorAnimation: false
            width: parent.width
            height: parent.height
            color:  DexTheme.comboBoxBackgroundColor
            border.color: DexTheme.comboBoxBorderColor
        }
    }
    DefaultMouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}