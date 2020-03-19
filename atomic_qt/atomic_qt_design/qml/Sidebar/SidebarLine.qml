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

    function isSettings() {
        return dashboard_index === General.idx_dashboard_settings
    }

    height: 48

    Image {
        id: img
        width: Style.textSize * 2
        fillMode: Image.PreserveAspectFit
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        visible: false
    }
    ColorOverlay {
        anchors.fill: img
        source: img
        color: txt.color
    }

    property bool hovered: false

    DefaultText {
        id: txt
        anchors.left: parent.left
        anchors.leftMargin: img.anchors.leftMargin + Style.textSize * 2.5
        anchors.verticalCenter: parent.verticalCenter
        font.bold: isSettings() ? settings_modal.visible : dashboard.current_page === dashboard_index
        color: font.bold ? Style.colorTheme0 : hovered ? Style.colorWhite1 : Style.colorWhite4
    }

    MouseArea {
        hoverEnabled: true
        onHoveredChanged: hovered = containsMouse
        width: parent.width
        height: parent.height
        onClicked: function() {
            if(isSettings()) settings_modal.open()

            else dashboard.current_page = dashboard_index
        }
    }
}




