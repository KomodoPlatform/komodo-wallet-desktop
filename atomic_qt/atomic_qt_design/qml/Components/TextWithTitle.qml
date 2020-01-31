import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12

Item {
    property alias title: title.text
    property alias text: text.text

    DefaultText {
        id: title
    }

    DefaultText {
        id: text
    }
}
