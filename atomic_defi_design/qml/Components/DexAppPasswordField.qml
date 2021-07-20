import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import Qaterial 1.0 as Qaterial


DexAppTextField {
    
    id: _inputPassword

    property string leftIcon: Qaterial.Icons.keyVariant

    height: 50
    width: 300
    background.border.width: 1
    background.radius: 25
    field.echoMode: TextField.Password
    field.font: Qt.font({
        pixelSize: (16 * theme.textType.fontDensity) * (Screen.pixelDensity / 160),
        letterSpacing: 0.5,
        family: theme.textType.fontFamily,
        weight: Font.Normal
    })
    Component.onCompleted: console.log(Screen.devicePixelRatio)
    field.horizontalAlignment: Qt.AlignLeft
    field.leftPadding: 75
    field.rightPadding: 60
    field.placeholderText: qsTr("Type password")
    DexRectangle {
        x: 5
        height: 40
        width: 60
        radius: 20
        color: _inputPassword.field.focus ? _inputPassword.background.border.color : theme.accentColor
        anchors.verticalCenter: parent.verticalCenter
        Qaterial.ColorIcon {
            anchors.centerIn: parent
            iconSize: 19
            source: _inputPassword.leftIcon
            color: theme.surfaceColor
        }

    }
    Qaterial.AppBarButton {
        opacity: .8
        icon {
            source: _inputPassword.field.echoMode === TextField.Password ? Qaterial.Icons.eyeOffOutline : Qaterial.Icons.eyeOutline
            color: _inputPassword.field.focus ? _inputPassword.background.border.color : theme.accentColor
        }
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 10
        }
        onClicked: {
            if (_inputPassword.field.echoMode === TextField.Password) {
                _inputPassword.field.echoMode = TextField.Normal
            } else {
                _inputPassword.field.echoMode = TextField.Password
            }
        }
    }
}