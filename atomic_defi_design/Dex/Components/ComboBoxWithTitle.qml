import QtQuick 2.15
import QtQuick.Layouts 1.15

ColumnLayout
{
    property alias title: title_text.text
    property alias field: input_field
    property alias model: input_field.model
    property alias currentIndex: input_field.currentIndex
    property alias currentText: input_field.currentText
    property alias currentValue: input_field.currentValue
    property alias textRole: input_field.textRole
    property alias valueRole: input_field.valueRole

    TitleText { id: title_text }

    DexComboBox
    {
        id: input_field
        Layout.preferredWidth: 300
    }
}
