import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

ColumnLayout {
    RowLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 20
        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            text_value: API.get().empty_string + (qsTr("Language") + ":")
            font.pixelSize: Style.textSizeSmall2
        }

        Grid {
            Layout.alignment: Qt.AlignVCenter

            clip: true

            columns: 8
            spacing: 10

            layoutDirection: Qt.LeftToRight

            Repeater {
                model: API.get().get_available_langs()
                delegate: Rectangle {
                    width: image.sourceSize.width - 4 // Current icons have too much space around them
                    height: image.sourceSize.height - 2
                    color: API.get().lang === model.modelData ? Style.colorTheme11 : "transparent"

                    Image {
                        id: image
                        anchors.centerIn: parent
                        source: General.image_path + "lang/" + model.modelData + ".png"
                        fillMode: Image.PreserveAspectFit
                        width: Style.textSize2

                        // Click area
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: {
                                API.get().lang = model.modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
