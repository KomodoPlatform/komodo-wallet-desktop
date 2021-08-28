import QtQuick 2.15
import QtQuick.Layouts 1.15
import App 1.0

ColumnLayout {
    property alias title: title.text
    property bool expandable: false
    property bool expanded: false
    readonly property bool show_content: !expandable || expanded

    RowLayout {
        id: row_layout
        Layout.fillWidth: true

        Arrow {
            id: arrow_icon
            visible: expandable
            up: expanded
            color: mouse_area.containsMouse ? Style.colorOrange : expanded ? DexTheme.redColor : DexTheme.greenColor
            Layout.alignment: Qt.AlignVCenter
        }

        TitleText {
            id: title
            Layout.fillWidth: true
            color: !expandable ? DexTheme.foregroundColorDarkColor4 : DexTheme.foregroundColorLightColor2
            font: DexTypo.body2
            opacity: .6
            DefaultMouseArea {
                id: mouse_area
                enabled: expandable
                anchors.fill: parent
                anchors.leftMargin: -arrow_icon.width - row_layout.spacing
                hoverEnabled: true
                onClicked: expanded = !expanded
            }
        }
    }
}
