import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import App 1.0

DexRectangle {
    id: control
    signal clicked()

    colorAnimation: false

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

    property int borderWidth: 3

    property real textScale: 1

    property string outlinedColor: ""

    property string button_type: "default"

    border.width: 0
    // end


    property alias label: _label
    property alias font: _label.font
    property alias leftPadding: _contentRow.leftPadding
    property alias rightPadding: _contentRow.rightPadding
    property alias topPadding: _contentRow.topPadding
    property alias bottomPadding: _contentRow.bottomPadding

    property string text: ""
    property string iconSource: ""
    
    property string foregroundColor: containsMouse ? DexTheme.buttonGradientTextEnabled : DexTheme.foregroundColor
    radius: 12

    Gradient {
        id: btnGradient
        orientation: Qt.Horizontal
        GradientStop {
            position: 0.1255
            color: DexTheme.buttonGradientEnabled1
        }
         GradientStop {
            position: 0.933
            color: DexTheme.buttonGradientEnabled2
        }
    }

    color: outlinedColor
    gradient: outlinedColor !== "" ? undefined : btnGradient

    DexRectangle {
        visible: !parent.containsMouse
        radius: parent.radius - 2
        anchors.centerIn: parent
        width: parent.width - (control.borderWidth*2)
        height: parent.height - (control.borderWidth*2)
        color: DexTheme.contentColorTopBold
        border.width: 0
    }
    height: _label.implicitHeight + (padding * verticalPadding)
    width: _contentRow.implicitWidth + (padding * horizontalPadding)

    Row
    {
        id: _contentRow

        anchors
        {
            horizontalCenter: parent.horizontalAlignment == Qt.AlignHCenter ? parent.horizontalCenter : undefined
            verticalCenter: parent.verticalAlignment == Qt.AlignVCenter ? parent.verticalCenter : undefined
        }

        spacing: _icon.visible ? parent.spacing : 0

        Qaterial.ColorIcon
        {
            id: _icon
            iconSize: _label.font.pixelSize + 2
            visible: control.iconSource === "" ? false : true
            source: control.iconSource
            color: _label.color
            anchors.verticalCenter: parent.verticalCenter
        }

        DexLabel
        {
            id: _label
            anchors.verticalCenter: parent.verticalCenter
            font: DexTypo.body2
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