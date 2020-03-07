import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

Rectangle {
    property int sort_type
    property alias text: title.text

    property bool hovered: false
    color: hovered ? Style.colorTheme7 : "transparent"
    width: title.width
    height: title.height

    // Click area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onHoveredChanged: hovered = containsMouse
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
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
