//! Qt Imports.
import QtQuick 2.12

//! Project Imports.
import "../Components"
import "../Constants"

Item
{
    id: root

    property alias label: _label

    signal clicked()

    height: Style.sidebarLineHeight

    DexLabel
    {
        id: _label

        anchors.left: parent.left
        anchors.leftMargin: 70
        anchors.verticalCenter: parent.verticalCenter

        font: Qt.font({
            pixelSize: 13 * DexTypo.fontDensity,
            letterSpacing: 0.25,
            family: DexTypo.fontFamily,
            weight: Font.Normal
        })
        style: Text.Normal
        color: _mouseArea.containsMouse ? Style.colorThemePassiveLight :
                                         Style.colorThemePassive
    }

    DexMouseArea
    {
        id: _mouseArea
        hoverEnabled: true
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
