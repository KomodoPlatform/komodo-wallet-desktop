import QtQuick 2.15
import QtQuick.Controls 2.15

Flickable {
    id: root

    property bool scrollbar_visible: contentHeight > height
    property int rightMargin: 3

    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: DexScrollBar {
        anchors.rightMargin: root.rightMargin
    }
 
    clip: true
}