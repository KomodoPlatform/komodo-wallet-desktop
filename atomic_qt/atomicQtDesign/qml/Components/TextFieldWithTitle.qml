import QtQuick 2.12
import QtQuick.Layouts 1.3
import Qt.SafeRenderer 1.1
import QtQuick.Studio.Effects 1.0
import QtQuick.Studio.Components 1.0
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12

ColumnLayout {
    property alias title: title_text.text
    property alias input_text: input_field.text

    DefaultText {
        id: title_text
    }

    TextField {
        id: input_field
        Layout.fillWidth: true
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
