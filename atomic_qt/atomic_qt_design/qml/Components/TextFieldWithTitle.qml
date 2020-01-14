import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field
    property bool hidable: false

    property bool hiding: true

    RowLayout {
        DefaultText {
            id: title_text
        }

        Button {
            id: button_show_hide
            visible: hidable
            text: hiding ? qsTr("Show") : qsTr("Hide")
            onClicked: hiding = !hiding
        }
    }

    TextField {
        id: input_field

        echoMode: hidable && hiding ? TextInput.Password : TextInput.Normal

        Layout.fillWidth: true
        selectByMouse: true
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
