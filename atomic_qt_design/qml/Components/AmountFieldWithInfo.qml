import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

TextFieldWithTitle {
    id: root

    field.validator: RegExpValidator {
        regExp: /(0|([1-9][0-9]*))(\.[0-9]{1,8})?/
    }

    field.font.pixelSize: Style.textSizeSmall1
    field.font.weight: Font.Bold
}
