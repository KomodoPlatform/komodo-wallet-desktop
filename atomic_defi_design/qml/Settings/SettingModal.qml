import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0


import QtQuick.Window 2.12

import Qaterial 1.0 as Qaterial
import "../Components"


Qaterial.Dialog {
    function disconnect() {
        API.app.disconnect()
        onDisconnect()
    }

    readonly property string mm2_version: API.app.settings_pg.get_mm2_version()
    property var recommended_fiats: API.app.settings_pg.get_recommended_fiats()
    property var fiats: API.app.settings_pg.get_available_fiats()



    id: setting_modal
    width: 850
    height: 650
    anchors.centerIn: parent
    dim: true
    modal: true
    title: "Settings"
    header: Item{}
    Overlay.modal: Item {
        Rectangle {
            anchors.fill: parent
            color: theme.surfaceColor
            opacity: .7
        }
    }
    background: FloatingBackground {
        color: theme.dexBoxBackgroundColor
        radius: 3
    }
    padding: 0
    topPadding: 0
    bottomPadding: 0
    Item {
        width: parent.width
        height: 60
        Qaterial.AppBarButton {
            anchors.right: parent.right
            anchors.rightMargin: 10
            icon.source: Qaterial.Icons.close
            anchors.verticalCenter: parent.verticalCenter
            onClicked: setting_modal.close()
        }
        Row {
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 20
            DexLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: "Settings"
                font: theme.textType.head6
            }
            DexLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: " - Géneral"
                opacity: .5
                font: theme.textType.head6
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom
            color: theme.foregroundColor
            opacity: .10
            width: parent.width
            height: 1.5
        }

        Qaterial.DebugRectangle {
            anchors.fill: parent
            visible: false
        }
    }
    Item {
        width: parent.width
        height: parent.height-110
        y:60
        RowLayout {
            anchors.fill: parent
            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 240
                ListView {
                    id: menu_list
                    anchors.fill: parent
                    anchors.topMargin: 10
                    spacing: 10
                    currentIndex: 0
                    model: ["Géneral", "Language","User Interface","About"]
                    highlight: Item {
                        width: menu_list.width-20
                        x: 10
                        height: 45
                        Rectangle {
                            anchors.fill: parent
                            height: 45
                            radius: 5
                            color: theme.hightlightColor
                        }
                    }

                    delegate: DexSelectableButton {
                        selected: false
                        text: modelData
                        onClicked: menu_list.currentIndex = index
                    }
                }
            }
            Rectangle {
                Layout.fillHeight: true
                width: 2
                color: theme.foregroundColor
                opacity: .10
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                StackLayout {
                    anchors.fill: parent
                    currentIndex: menu_list.currentIndex
                    Item {
                        ComboBoxWithTitle {
                            id: combo_fiat
                            title: qsTr("Fiat")
                            Layout.fillWidth: true
                            Layout.leftMargin: 30
                            Layout.rightMargin: Layout.leftMargin

                            model: fiats

                            property bool initialized: false
                            onCurrentIndexChanged: {
                                if(initialized) {
                                    const new_fiat = fiats[currentIndex]
                                    API.app.settings_pg.current_fiat = new_fiat
                                    API.app.settings_pg.current_currency = new_fiat
                                }
                            }
                            Component.onCompleted: {
                                currentIndex = model.indexOf(API.app.settings_pg.current_fiat)
                                initialized = true
                            }

                            RowLayout {
                                Layout.topMargin: 5
                                Layout.fillWidth: true
                                Layout.leftMargin: 2
                                Layout.rightMargin: Layout.leftMargin

                                DefaultText {
                                    text: qsTr("Recommended: ")
                                    font.pixelSize: Style.textSizeSmall4
                                }

                                Grid {
                                    Layout.leftMargin: 30
                                    Layout.alignment: Qt.AlignVCenter

                                    clip: true

                                    columns: 6
                                    spacing: 25

                                    layoutDirection: Qt.LeftToRight

                                    Repeater {
                                        model: recommended_fiats

                                        delegate: DefaultText {
                                            text: modelData
                                            color: fiats_mouse_area.containsMouse ? Style.colorText : Style.colorText2

                                            DefaultMouseArea {
                                                id: fiats_mouse_area
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: {
                                                    API.app.settings_pg.current_fiat = modelData
                                                    API.app.settings_pg.current_currency = modelData
                                                    combo_fiat.currentIndex = combo_fiat.model.indexOf(API.app.settings_pg.current_fiat)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Item {
                        DexLabel {
                            text: "test p2"
                        }
                    }
                }
            }
        }

        Qaterial.DebugRectangle {
            anchors.fill: parent
            visible: false
        }
    }
    Item {
        width: parent.width
        height: 50
        anchors.bottom: parent.bottom
        DexSelectableButton {
            selected: true
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.horizontalCenter: undefined
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            height: 40
            width: 130
            Row {
                anchors.centerIn: parent
                Qaterial.ColorIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qaterial.Icons.logout
                }
                spacing: 10
                DexLabel {
                    text: "Logout"
                    anchors.verticalCenter: parent.verticalCenter
                    font: theme.textType.button
                }
                opacity: .6
            }

        }

        Rectangle {
            anchors.top: parent.top
            color: theme.foregroundColor
            opacity: .10
            width: parent.width
            height: 1.5
        }

    }

    Component.onCompleted: {
        //open()
    }
}
