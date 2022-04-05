// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

// Project Imports
import Dex.Components 1.0 as Dex
import Dex.Themes 1.0 as Dex

ColumnLayout
{
    Row
    {
        Layout.fillWidth: true
        implicitHeight: childrenRect.height

        Dex.DefaultText
        {
            text: qsTr("Address Book")
        }
    }
}
