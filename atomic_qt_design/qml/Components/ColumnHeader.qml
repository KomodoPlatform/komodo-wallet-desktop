import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Constants"

Item {
    property int sort_type
    property alias text: title.text_value

    property bool icon_at_left

    width: text.length * title.font.pixelSize
    height: title.height

    // Click area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if(current_sort === sort_type) {
                highest_first = !highest_first
            }
            else {
                current_sort = sort_type
                highest_first = true
            }
        }
    }

    DefaultText {
        id: title
        color: Style.colorWhite1
        anchors.left: icon_at_left ? parent.left : undefined
        anchors.right: icon_at_left ? undefined : parent.right
    }


    // Arrow icon
    Image {
        id: arrow_icon

        source: General.image_path + "arrow-" + (highest_first ? "down" : "up") + ".svg"

        width: title.font.pixelSize * 0.5
        fillMode: Image.PreserveAspectFit

        anchors.left: icon_at_left ? title.right : undefined
        anchors.leftMargin: icon_at_left ? 10 : undefined
        anchors.right: icon_at_left ? undefined : title.left
        anchors.rightMargin: icon_at_left ? undefined : 10
        anchors.verticalCenter: title.verticalCenter

        visible: false
    }

    ColorOverlay {
        visible: current_sort === sort_type
        anchors.fill: arrow_icon
        source: arrow_icon
        color: title.color
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
