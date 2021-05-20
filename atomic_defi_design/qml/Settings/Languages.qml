import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

ColumnLayout {
    property alias show_label: label.visible

    RowLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 20
        DefaultText {
            id: label
            visible: false
            Layout.alignment: Qt.AlignVCenter
            text_value: qsTr("Language") + ":"
            font.pixelSize: Style.textSizeSmall2
        }

        Grid {
            Layout.alignment: Qt.AlignVCenter

            clip: true

            columns: 8
            spacing: 10

            layoutDirection: Qt.LeftToRight

            Repeater {
                model: API.app.settings_pg.get_available_langs()
                delegate: AnimatedRectangle {
                    width: image.sourceSize.width - 4 // Current icons have too much space around them
                    height: image.sourceSize.height - 2

                    color: API.app.settings_pg.lang === model.modelData ? Style.colorTheme11 : mouse_area.containsMouse ? Style.colorTheme4 : Style.applyOpacity(Style.colorTheme4)

                    DefaultImage {
                        id: image
                        anchors.centerIn: parent
                        source: General.image_path + "lang/" + model.modelData + ".png"
                        width: Style.textSize2
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
