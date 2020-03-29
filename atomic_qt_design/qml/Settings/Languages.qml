import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

ColumnLayout {
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            text: API.get().empty_string + (qsTr("Language"))
        }
        Image {
            Layout.alignment: Qt.AlignBottom
            source: General.image_path + "lang/" + API.get().lang + ".png"
            fillMode: Image.PreserveAspectFit
            scale: 0.5
        }
    }

    Grid {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 10
        clip: true

        columns: 8
        spacing: 10

        layoutDirection: Qt.LeftToRight

        Repeater {
            model: API.get().get_available_langs()
            delegate: Image {
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
