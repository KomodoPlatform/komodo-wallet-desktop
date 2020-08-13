import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Content
ColumnLayout {
    property var details

    // Title
    DefaultText {
        text_value: API.get().settings_pg.empty_string + (qsTr("Swap Progress"))
    }

    DefaultText {
        text_value: API.get().settings_pg.empty_string + (qsTr("Events: ") + (!details ? 0 : details.events.length))
    }
}
