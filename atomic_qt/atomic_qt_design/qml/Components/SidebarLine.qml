import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Constants"

Item {
    property int dashboard_index
    property alias image: img.source
    property alias text: txt.text

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


    DefaultText {
        id: txt
        anchors.left: parent.left
        anchors.leftMargin: img.anchors.leftMargin + Style.textSize * 2.5
        anchors.verticalCenter: parent.verticalCenter
        color: dashboard.current_page === dashboard_index ? Style.colorTheme0 : Style.colorWhite1
    }

    MouseArea {
        width: parent.width
        height: parent.height
        onClicked: function() {
            dashboard.current_page = dashboard_index
        }
    }
}




