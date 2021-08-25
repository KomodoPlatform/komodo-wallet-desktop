import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import App 1.0

DexRectangle {
    id: control
    signal clicked()

    property int padding: 12
    property int spacing: 4
    property int verticalAlignment: Qt.AlignVCenter
    property int horizontalAlignment: Qt.AlignHCenter
    property int verticalPadding: 2
    property int horizontalPadding: 2


    // old button property
    property alias text_obj: _label
    property alias containsMouse: _controlMouseArea.containsMouse

    property bool text_left_align: false

    property int minWidth: 90

    property real textScale: 1

    property string button_type: "default"
    // end


    property alias label: _label
    property alias font: _label.font
    property alias leftPadding: _contentRow.leftPadding
    property alias rightPadding: _contentRow.rightPadding
    property alias topPadding: _contentRow.topPadding
    property alias bottomPadding: _contentRow.bottomPadding

    property string text: ""
    property string iconSource: ""
    
    property string foregroundColor: DexTheme.buttonGradientTextEnabled
    radius: 5
    gradient: Gradient {
        orientation: Qt.Horizontal
        GradientStop {
            position: 0.1255
            color: control.containsMouse ? Qt.lighter(DexTheme.buttonGradientEnabled1) : DexTheme.buttonGradientEnabled1
        }
         GradientStop {
            position: 0.933
            color: control.containsMouse ? Qt.lighter(DexTheme.buttonGradientEnabled2) : DexTheme.buttonGradientEnabled2
        }
    }
    height: _label.implicitHeight + (padding * verticalPadding)
    width: _contentRow.implicitWidth + (padding * horizontalPadding)

    Row {
        id: _contentRow

        anchors {
            horizontalCenter: parent.horizontalAlignment == Qt.AlignHCenter ? parent.horizontalCenter : undefined
            verticalCenter: parent.verticalAlignment == Qt.AlignVCenter ? parent.verticalCenter : undefined
        }

        spacing: _icon.visible ? parent.spacing : 0
        Qaterial.ColorIcon {
            id: _icon
            iconSize: _label.font.pixelSize + 2
            visible: control.iconSource === "" ? false : true
            source: control.iconSource
            color: _label.color
            anchors.verticalCenter: parent.verticalCenter
        }

        DexLabel {
            id: _label
            anchors.verticalCenter: parent.verticalCenter
            font: DexTypo.button
            text: control.text
            color: control.foregroundColor
        }
    }
    DexMouseArea {
        id: _controlMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.clicked()
    }
}