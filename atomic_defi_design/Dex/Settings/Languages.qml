import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"
import App 1.0

ColumnLayout {
    property alias show_label: label.visible

    RowLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 5
        DexLabel {
            id: label
            visible: false
            Layout.alignment: Qt.AlignVCenter
            font: DexTypo.subtitle1
            text_value: qsTr("Language") + ":"
        }

        Grid {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

            clip: true

            columns: 8
            spacing: 10

            Repeater {
                model: API.app.settings_pg.get_available_langs()
                delegate: ClipRRect {
                    width: 30 // Current icons have too much space around them
                    height: 30
                    radius: 15
                    //color: API.app.settings_pg.lang === model.modelData ? Style.colorTheme11 : mouse_area.containsMouse ? Style.colorTheme4 : Style.applyOpacity(Style.colorTheme4)

                    DefaultImage {
                        id: image
                        anchors.centerIn: parent
                        source: General.image_path + "lang/" + model.modelData + ".png"
                        width: 40
                        height: 40
                        // Click area
                        DefaultMouseArea {
                            id: mouse_area
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            hoverEnabled: true
                            onClicked: {
                                API.app.settings_pg.lang = model.modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
