import QtQuick 2.14
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
        delegate: DefaultTextEdit {
            text_value: API.get().settings_pg.empty_string + (model.modelData)
            color: Style.modalValueColor
            privacy: true
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
