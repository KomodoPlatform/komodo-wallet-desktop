import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field

    DefaultText {
        id: title_text
    }

    TextField {
        id: input_field
        Layout.fillWidth: true
        selectByMouse: true
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
