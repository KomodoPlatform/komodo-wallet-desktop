import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Constants"

ColumnLayout {
    property alias title: title_text.text
    property alias field: input_field

    RowLayout {
        DefaultText {
            id: title_text
        }
    }

    DefaultComboBox {
        id: input_field
        Layout.fillWidth: true
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
