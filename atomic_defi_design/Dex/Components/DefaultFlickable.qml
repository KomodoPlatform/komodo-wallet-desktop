import QtQuick 2.15
import QtQuick.Controls 2.15

Flickable
{
    id: root

    property bool scrollbar_visible: contentHeight > height

    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: DefaultScrollBar { }

    clip: true
}
