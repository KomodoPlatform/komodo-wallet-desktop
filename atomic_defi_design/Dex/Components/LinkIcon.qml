import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"
import App 1.0

Circle {
    property string link
    property alias source: icon.source
    property alias text: tooltip_text.text_value

    Layout.preferredWidth: 60
    Layout.preferredHeight: Layout.preferredWidth

    color: Style.colorOnlyIf(mouse_area.containsMouse, Style.colorTheme4)

    radius: 100

    DefaultImage {
        id: icon

        width: parent.width * 0.9
        height: parent.height * 0.9

        anchors.centerIn: parent

        DefaultMouseArea {
            id: mouse_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Qt.openUrlExternally(link)
        }

        DefaultTooltip {
            visible: mouse_area.containsMouse

            contentItem: ColumnLayout {
                DefaultText {
                    id: tooltip_text
                }
            }
        }
    }
}
