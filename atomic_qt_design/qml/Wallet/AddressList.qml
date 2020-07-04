import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

ColumnLayout {
    property alias title: title.text
    property alias model: list.model

    Layout.fillWidth: true

    DefaultText {
        id: title
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: contentItem.childrenRect.height

        clip: true

        // Row
        delegate: DefaultText {
            text_value: API.get().empty_string + (model.modelData)
            color: Style.modalValueColor
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
