import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ScrollBar {
    id: control
    width: 6

    contentItem: FloatingBackground {
        radius: 100
    }
    background: InnerBackground {
        width: control.width + 4
        x: -width/2 + control.width/2
        radius: 100
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

