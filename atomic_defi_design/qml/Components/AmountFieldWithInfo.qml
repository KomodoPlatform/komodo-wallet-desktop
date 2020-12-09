import QtQuick 2.15
import "../Constants/Style.qml" as Style

TextFieldWithTitle {
    id: root

    field.validator: RegExpValidator {
        regExp: /(0|([1-9][0-9]*))(\.[0-9]{1,8})?/
    }

    field.horizontalAlignment: Qt.AlignRight

    field.font.pixelSize: Style.textSizeSmall1
    field.font.weight: Font.Medium
}
