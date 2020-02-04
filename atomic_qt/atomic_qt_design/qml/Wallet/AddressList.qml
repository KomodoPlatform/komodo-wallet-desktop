import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
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
            text: model.modelData
            color: Style.modalValueColor
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
