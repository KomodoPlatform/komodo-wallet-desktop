import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15

import "../Constants"

ComboBox {
    id: control
    property var dropdownLineText: m => textRole === "" ?
                                       m.modelData :
                                       !m.modelData ? m[textRole] : m.modelData[textRole]
    property string currentTicker: "All"
    delegate: ItemDelegate {
        width: control.width+50
        highlighted: control.highlightedIndex === index
        contentItem: DefaultText {
            text_value: control.currentTicker
            color: Style.colorText
        }
    }

    indicator: ColorImage {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        color: control.contentItem.color
        defaultColor: control.contentItem.color
        source: "qrc:/qt-project.org/imports/QtQuick/Controls.2/images/double-arrow.png"
    }

    contentItem: DefaultText {
        leftPadding: 10
        rightPadding: control.indicator.width + control.spacing
        color: Style.colorWhite1
        text: control.currentTicker//control.displayText

        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: !control.enabled ? Style.colorTheme5 : control.hovered ? Style.colorTheme7 : Style.colorTheme9
        radius: 4
    }

    popup: Popup {
        id: comboPopup
        readonly property double max_height: 350
        y: control.height - 1
        width: control.width+50
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
                        anchors.rightMargin: 2
                       border.color: "transparent"
                       color: Style.colorInnerBackground
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
                    function onClosed() { input_coin_filter.reset() }
                }



                font.pixelSize: 16
                Layout.fillWidth: true
                Layout.leftMargin: 0
                Layout.preferredHeight: 40
                Layout.rightMargin: 2//Layout.leftMargin
                Layout.topMargin: Layout.leftMargin
                Keys.onDownPressed:  {
                    control.incrementCurrentIndex()
                }
                Keys.onUpPressed: {
                    control.decrementCurrentIndex()
                }

                Keys.onPressed: {
                    if(event.key === Qt.Key_Return) {
                        if(control.count > 0) {
                            control.currentIndex = 0//control.highlightedIndex
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
                DefaultListView {
                    id: popup_list_view
                    model: control.popup.visible ? control.model : null
                    currentIndex: control.highlightedIndex
                    anchors.fill: parent
                    anchors.rightMargin: 2
                    delegate: ItemDelegate {
                        width: control.width+50
                        highlighted: control.highlightedIndex === index
                        contentItem: DefaultText {
                            text_value: ticker
                            color: Style.colorText
                        }
                        onClicked: {
                            control.currentTicker = ticker
                            popup.close()
                        }
                    }

                    DefaultMouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                    }
                }
            }

        }

        background: Item {
            AnimatedRectangle {
                width: parent.width
                y: -5
                height: parent.height+10
                color: Style.colorTheme9
            }
        }
    }
    DefaultMouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
