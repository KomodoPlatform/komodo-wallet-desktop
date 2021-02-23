import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import "../Constants"


Item {
    id: root
    property string top_arrow_ticker
    property string bottom_arrow_ticker

    property bool hovered: false

    implicitWidth: 20
    implicitHeight: 50

    Qaterial.ColorIcon {
        anchors.centerIn: parent
        source: Qaterial.Icons.swapHorizontal
        color: Style.colorWhite4
    }
}
