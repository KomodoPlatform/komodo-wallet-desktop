import QtQuick 2.15
import "../Constants"

AnimatedRectangle {
    visible: update_needed && status_good

    color: Style.colorGreen
    height: 30 + radius
    width: text.width + 30 + radius

    anchors.topMargin: -radius
    anchors.rightMargin: -radius

    radius: Style.rectangleCornerRadius

    DefaultText {
        id: text
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -parent.radius * 0.5
        anchors.verticalCenterOffset: parent.radius * 0.4

        text: General.download_icon + " " + qsTr("New update available!") + " " + qsTr("Version:") + " " + API.app.update_checker.update_status.new_version + "  -  " + qsTr("Click here for the details.")
        font.pixelSize: Style.textSizeSmall3
        color: Style.colorWhite10
    }

    DefaultMouseArea {
        anchors.fill: parent
        onClicked: update_modal.open()
    }
}
