import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    padding: 10

    width: 900
    height: column_layout.height + verticalPadding * 2

    property alias currentIndex: stack_layout.currentIndex
    property alias count: stack_layout.count
    default property alias pages: stack_layout.data

    function nextPage() {
        if(currentIndex === count - 1) root.close()
        else currentIndex += 1
    }

    function previousPage() {
        if(currentIndex === 0) root.close()
        else currentIndex -= 1
    }

    Column {
        id: column_layout
        spacing: Style.rowSpacing
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter

        DefaultText {
            id: page_indicator
            visible: root.count > 1
            text_value: API.get().settings_pg.empty_string + (qsTr("Page") + " " + (root.currentIndex + 1) + " / " + root.count)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        HorizontalLine {
            id: horizontal_line
            visible: page_indicator.visible
            width: parent.width
        }

        // Inside modal
        StackLayout {
            id: stack_layout
            width: parent.width
            height: stack_layout.children[stack_layout.currentIndex].height
        }
    }
}
