import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

Item {
    id: root

    function reset() {

    }

    function onOpened() {
        if(mm2_version === '') mm2_version = API.get().get_mm2_version()
    }

    DefaultFlickable {
        id: layout_background

        anchors.fill: parent
        anchors.margins: 20

        contentWidth: width
        contentHeight: content_layout.height

        ColumnLayout {
            id: content_layout
            width: parent.width
            spacing: 40

            DefaultText {
                Layout.alignment: Qt.AlignHCenter
                text_value: API.get().settings_pg.empty_string + (qsTr("Link icons will be here"))
            }

            HorizontalLine {
                Layout.fillWidth: true
            }

            DefaultText {
                Layout.alignment: Qt.AlignHCenter
                text_value: API.get().settings_pg.empty_string + (qsTr("Frequently Asked Questions"))
                font.pixelSize: Style.textSize2
            }

            TextWithTitle {
                Layout.fillWidth: true
                title: API.get().settings_pg.empty_string + (qsTr("What is Komodo?"))
                text: API.get().settings_pg.empty_string + (qsTr("Komodo is an open, composable multi-chain platform. With blockchain development roots going back to 2014, Komodo is consistently recognized as a pioneer of multi-chain architecture in the blockchain space."))
            }

            TextWithTitle {
                Layout.fillWidth: true
                title: API.get().settings_pg.empty_string + (qsTr("What is the mission of Komodo?"))
                text: API.get().settings_pg.empty_string + (qsTr("Komodo is committed to accelerating global blockchain adoption through a composable, multi-chain architecture, an open-source model, and an open, business-friendly ecosystem that allows developers, start-ups, and enterprises alike to prosper with blockchain technology."))
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
