import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import Qaterial 1.0 as Qaterial
import App 1.0


DexAppTextField {

    id: _inputPassword

    property string leftIcon: Qaterial.Icons.keyVariant

    height: 50
    width: 300
    background.border.width: 1
    background.radius: 25
    max_length: 1000
    field.echoMode: TextField.Password
    field.font: Qt.font({
        pixelSize: (16 * DexTypo.fontDensity) * (Screen.pixelDensity / 160),
        letterSpacing: 0.5,
        family: DexTypo.fontFamily,
        weight: Font.Normal
    })
    field.horizontalAlignment: Qt.AlignLeft
    field.leftPadding: 75
    field.rightPadding: 60
    field.placeholderText: qsTr("Type password")
    DexRectangle {
        x: 5
        height: 40
        width: 60
        radius: 20
        color: _inputPassword.field.focus ? _inputPassword.background.border.color : DexTheme.accentColor
        anchors.verticalCenter: parent.verticalCenter
        Qaterial.ColorIcon {
            anchors.centerIn: parent
            iconSize: 19
            color: DexTheme.backgroundColor
            source: _inputPassword.leftIcon
        }

    }
    Qaterial.AppBarButton {
        opacity: .8
        icon {
            source: _inputPassword.field.echoMode === TextField.Password ? Qaterial.Icons.eyeOffOutline : Qaterial.Icons.eyeOutline
            color: _inputPassword.field.focus ? _inputPassword.background.border.color : DexTheme.accentColor
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