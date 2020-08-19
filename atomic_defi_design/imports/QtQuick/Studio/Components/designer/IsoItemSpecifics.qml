import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0


Column {
    anchors.left: parent.left
    anchors.right: parent.right

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: qsTr("Icon Color")

        ColorEditor {
            caption: qsTr("Icon Color")
            backendValue: backendValues.color
            supportGradient: false
        }
    }
}
