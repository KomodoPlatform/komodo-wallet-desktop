import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"
import App 1.0

Circle
{
    property string link
    property alias source: icon.source
    property alias text: tooltip_text.text

    Layout.preferredWidth: 50
    Layout.preferredHeight: Layout.preferredWidth
    Layout.margins: 5

    color: Style.colorOnlyIf(mouse_area.containsMouse, Style.colorTheme4)

    radius: 100

    DexImage
    {
        id: icon
        anchors.centerIn: parent

        width: parent.width * 0.9
        height: parent.height * 0.9
    }

    DexMouseArea
    {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Qt.openUrlExternally(link)
    }

    DexTooltip
    {
        visible: mouse_area.containsMouse
        id: tooltip_text
    }
}
