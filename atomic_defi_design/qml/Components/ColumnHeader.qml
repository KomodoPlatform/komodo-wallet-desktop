import QtQuick 2.15
import "../Constants"
import App 1.0

Item {
    property int sort_type
    property alias text: title.text_value

    property bool icon_at_left

    width: text.length * title.font.pixelSize
    height: title.height

    // Click area
    

    DefaultText {
        id: title
        anchors.left: icon_at_left ? parent.left : undefined
        anchors.right: icon_at_left ? undefined : parent.right

        //color: Qt.lighter(DexTheme.accentColor, click_area.containsMouse ? Style.hoverLightMultiplier : 1.0)
    }


    // Arrow icon
    DefaultImage {
        id: arrow_icon

        source: General.image_path + "arrow-" + (ascending ? "down" : "up") + ".svg"

        width: title.font.pixelSize * 0.5

        anchors.left: icon_at_left ? title.right : undefined
        anchors.leftMargin: icon_at_left ? 10 : undefined
        anchors.right: icon_at_left ? undefined : title.left
        anchors.rightMargin: icon_at_left ? undefined : 10
        anchors.verticalCenter: title.verticalCenter

        visible: false
    }

    DefaultColorOverlay {
        visible: current_sort === sort_type
        anchors.fill: arrow_icon
        source: arrow_icon
        color: title.color
    }
    DefaultMouseArea {
        id: click_area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked: {
            if(current_sort === sort_type) {
                ascending = !ascending
            }
            else {
                current_sort = sort_type
                ascending = false
            }

            applyCurrentSort()
        }
    }
}
