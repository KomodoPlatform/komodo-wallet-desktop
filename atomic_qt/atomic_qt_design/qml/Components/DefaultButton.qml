import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

Button {
    background: Rectangle {
        color: Style.colorTheme2
        border.width: 1
        border.color: Style.colorTheme2
        radius: 20
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onPressed: parent.color = Style.colorTheme4
          onReleased: parent.color = Style.colorTheme2
          onEntered: parent.color = Style.colorTheme3
          onClicked: parent.color = Style.colorTheme1
          onExited: parent.color = Style.colorTheme2
       }
    }

    leftPadding: parent.width * 0.075
    rightPadding: parent.width * 0.075
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
