import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

Item {
    property int dashboard_index
    property alias image: img.source
    property alias text: txt.text

    height: 48

    Image {
        id: img
        width: txt.font.pixelSize * 2
        fillMode: Image.PreserveAspectFit
        anchors.left: parent.left
        anchors.leftMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        visible: false
    }
    ColorOverlay {
        anchors.fill: img
        source: img
        color: txt.font.bold ? Style.colorGreen : txt.color
    }

    DefaultText {
        id: txt
        anchors.right: parent.right
        anchors.rightMargin: img.anchors.leftMargin
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: Style.textSizeSmall2
        font.bold: dashboard.current_page === dashboard_index
        color: font.bold ? Style.colorWhite1 : mouse_area.containsMouse ? Style.colorThemePassiveLight : Style.colorThemePassive
    }

    MouseArea {
        id: mouse_area
        hoverEnabled: true
        width: parent.width
        height: parent.height
        onClicked: function() {
            dashboard.current_page = dashboard_index
        }
    }
}




