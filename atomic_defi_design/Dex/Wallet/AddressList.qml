import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import App 1.0

ColumnLayout
{
    property alias title: title.text
    property alias model: list.model

    TitleText
    {
        id: title
        opacity: .6
    }

    ListView
    {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: contentItem.childrenRect.height

        clip: true

        delegate: DefaultText
        {
            text_value: model.modelData
            privacy: true
        }
    }
}
