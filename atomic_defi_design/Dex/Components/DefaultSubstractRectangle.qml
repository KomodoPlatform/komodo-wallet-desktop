import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0
import AtomicDEX.MarketMode 1.0

import "../Constants"
import App 1.0

Rectangle {
    id: _mask
    property var target
    property alias subStractItem: maskSubstract
    anchors.fill: target
    color: "transparent"
    visible: true
    radius: 10
    Rectangle {
        id: maskSubstract
        x: parent.width-20
        anchors.verticalCenter: parent.verticalCenter
        radius: 100
        width: 60
        height: 60
    }
    layer.enabled: true
    layer.samplerName: "maskSource"
    layer.effect: ShaderEffect {
        property variant source: _mask.target
        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform lowp sampler2D source;
            uniform lowp sampler2D maskSource;
            void main(void) {
            gl_FragColor = texture2D(source, qt_TexCoord0.st) * (1.0-texture2D(maskSource, qt_TexCoord0.st).a) * qt_Opacity;
            }
                                            "
    }
}
