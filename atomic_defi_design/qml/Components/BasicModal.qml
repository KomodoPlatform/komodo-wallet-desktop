import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    padding: 10

    width: 900
    height: stack_layout.children[stack_layout.currentIndex].height + verticalPadding * 2

    property alias currentIndex: stack_layout.currentIndex
    default property alias pages: stack_layout.data

    function nextPage() {
        if(currentIndex === stack_layout.count - 1) root.close()
        else currentIndex += 1
    }
    function previousPage() {
        if(currentIndex === 0) root.close()
        else currentIndex -= 1
    }

    // Inside modal
    StackLayout {
        id: stack_layout
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
