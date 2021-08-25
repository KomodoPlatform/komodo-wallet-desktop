import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0


import QtQuick.Window 2.12

import Qaterial 1.0 as Qaterial

// Project Imports
import "../Components"
import "../Constants"
import App 1.0


ComboBoxWithTitle {
    id: combo_fiat
    title: qsTr("Fiat")
    width: parent.width-30
    anchors.horizontalCenter: parent.horizontalCenter

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
                    color: DexTheme.foregroundColor
                    opacity: fiats_mouse_area.containsMouse ? .7 : 1

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
