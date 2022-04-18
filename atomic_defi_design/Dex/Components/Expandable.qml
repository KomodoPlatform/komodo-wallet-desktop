import QtQuick 2.12

Rectangle
{
    id: root

    property bool   isExpanded: false
    property real   padding: 10

    property alias  header: headerLoader.sourceComponent
    property alias  content: contentLoader.sourceComponent

    implicitHeight: padding + headerLoader.implicitHeight + contentLoader.implicitHeight
    clip: true

    Loader
    {
        id: headerLoader

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: root.padding
    }

    Loader
    {
        id: contentLoader

        visible: root.isExpanded

        anchors.top: headerLoader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: root.padding
    }
}
