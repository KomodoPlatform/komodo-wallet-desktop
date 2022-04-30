import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15


Item {
    property var target
    visible: !target.visible

    anchors.fill: parent

    DexBusyIndicator {
        anchors.centerIn: parent
    }
}
