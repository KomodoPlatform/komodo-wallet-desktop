import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

Text {
    property string text_value
    property bool privacy: false

    font.family: Style.font
    font.pixelSize: Style.textSize
    color: Style.colorText
    text: General.privacy_mode ? "*****" : text_value
    wrapMode: Text.WordWrap
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

