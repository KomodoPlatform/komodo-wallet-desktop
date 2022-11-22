import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Layouts 1.5

import App 1.0

Item {
    id: control
    width: 200
    height: 35
    property alias value: input_field.text
    property alias field: input_field
    property alias background: _background
    property string defaultBorderColor: DexTheme.rectangleBorderColor
    property string leftText: ""
    property string rightText: ""
    property string placeholderText: ""
    property int leftWidth: -1
    property int max_length: 40
    property bool error: false
    onErrorChanged: {
        if (error) {
            _animationTimer.start()
            _animate.start()
        }
    }
    Timer {
        id: _animationTimer
        interval: 350
        onTriggered: {
            _animate.stop()
            _background.x = 0
        }
    }
    Timer {
        id: _animate
        interval: 30
        repeat: true
        onTriggered: {
            if (_background.x == -3) {
                _background.x = 3
            } else {
                _background.x = -3
            }
        }
    }

    function reset() {
        input_field.text = ""
    }

    Rectangle {
        id: _background
        width: parent.width
        height: parent.height
        radius: 25
        color: 'transparent'
        border.color: DexTheme.accentColor
        border.width: input_field.focus ? 1 : 0
        Behavior on x {
            NumberAnimation {
                duration: 40
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        spacing: 2
        Item {
            visible: leftText !== ""
            Layout.preferredWidth: leftWidth !== -1 ? leftWidth : _title_label.implicitWidth + 2
            Layout.fillHeight: true
            DexLabel {
                id: _title_label
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 5
                horizontalAlignment: DexLabel.AlignHCenter
                text: leftText
                color: DexTheme.foregroundColor
                opacity: .4
                font.pixelSize: 14
                font.weight: Font.Medium
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 1
                anchors.bottomMargin: 1
                radius: _background.radius
                color: _background.color
                DexTextField {
                    id: input_field
                    onTextChanged: {
                        if (text.length > control.max_length) {
                            text = text.substring(0, control.max_length)
                        }
                        control.error = false
                    }
                    horizontalAlignment: Qt.AlignLeft
                    echoMode: TextInput.Normal
                    background: Item {}
                    font.weight: Font.Medium
                    font.family: 'Lato'
                    font.pixelSize: 13
                    anchors.fill: parent
                }
                DexLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: input_field.leftPadding
                    font: input_field.font
                    color: DexTheme.foregroundColor
                    opacity: .5
                    text: control.placeholderText
                    visible: input_field.text === ""
                }
            }
        }
        Item {
            visible: rightText !== ""
            Layout.preferredWidth: _suffix_label.implicitWidth + 2
            Layout.fillHeight: true
            DexLabel {
                id: _suffix_label
                anchors.centerIn: parent
                horizontalAlignment: DexLabel.AlignHCenter
                text: rightText
                color: DexTheme.foregroundColor
                opacity: .4
                font.pixelSize: 14
                font.weight: Font.Medium
            }
        }
    }
}
