import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Universal 2.15

import QtGraphicalEffects 1.0

import "../Constants"

DexComboBox {
    id: control
    model: API.app.settings_pg.get_available_langs()
    displayText: API.app.settings_pg.lang
    delegate: ItemDelegate {
        width: control.width
        height: 30
        highlighted: control.highlightedIndex === index
        RowLayout {
            anchors.fill: parent
            spacing: -13
            DefaultImage {
                id: image
                Layout.preferredHeight: 14
                source: General.image_path + "lang/" + modelData + ".png"
            }
            DexLabel {
                text: modelData

            }
        }
        onClicked: {
            if(modelData !== API.app.settings_pg.lang) {
                API.app.settings_pg.lang =  modelData
            } 
        }
    }
    contentItem: Text {
        leftPadding: 0
        rightPadding: control.indicator.width + control.spacing

        //text: control.displayText
        font: control.font
        color: control.pressed ? "#17a81a" : "#21be2b"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        DefaultImage {
            id: image
            height: 14
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            source: General.image_path + "lang/" + control.displayText + ".png"
        }
    }
    indicator: ColorImage {
        x: control.width - 34
        y: control.topPadding + (control.availableHeight - height) / 2
        color: theme.rectangleBorderColor
        defaultColor: control.contentItem.color
        scale: .7
        source: "qrc:/qt-project.org/imports/QtQuick/Controls.2/images/double-arrow.png"
    }
}
