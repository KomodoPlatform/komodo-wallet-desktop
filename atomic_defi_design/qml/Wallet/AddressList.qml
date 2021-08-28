import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import App 1.0

ColumnLayout {
    property alias title: title.text
    property alias model: list.model

    Layout.fillWidth: true

    TitleText {
        id: title
        opacity: .6
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: contentItem.childrenRect.height

        clip: true

        // Row
        delegate: DefaultTextEdit {
            text_value: model.modelData
            color: DexTheme.foregroundColor
            privacy: true
        }
    }
}
