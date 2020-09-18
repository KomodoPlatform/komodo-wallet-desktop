import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

Rectangle {
    visible: update_modal.update_needed && update_modal.status_good

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

        text: API.app.settings_pg.empty_string + (General.download_icon + " " + qsTr("New update available!") + " " + qsTr("Version:") + " " + API.app.update_status.new_version + "  -  " + qsTr("Click here for the details."))
        font.pixelSize: Style.textSizeSmall3
        color: Style.colorWhite10
    }

    MouseArea {
        anchors.fill: parent
        onClicked: update_modal.open()
    }
}
