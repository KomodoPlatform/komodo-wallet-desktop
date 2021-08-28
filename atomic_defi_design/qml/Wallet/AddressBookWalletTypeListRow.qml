import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import App 1.0

ItemDelegate {
    property string ticker
    property string name

    property alias icon_source: icon.source

    height: 50

    RowLayout {
        DefaultImage {
            id: icon
            Layout.topMargin: 10
            Layout.leftMargin: 30
            Layout.alignment: Qt.AlignVCenter
            source: General.coinIcon(ticker)
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
        }

        DexLabel {
            Layout.topMargin: 10
            text: "    " + name + " (" + ticker + ")"
        }
    }

}
