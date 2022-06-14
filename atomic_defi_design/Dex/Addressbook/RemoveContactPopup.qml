// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

// Project Imports
import "../Constants" as Dex
import Dex.Components 1.0 as Dex

Dex.Popup
{
    id: root

    property string contactName

    width: 140
    height: 120

    contentItem: ColumnLayout
    {
        spacing: 8
        width: root.width

        Dex.Text
        {
            Layout.fillWidth: true
            text: qsTr("Do you want to remove this contact ?")
        }

        Row
        {
            Layout.fillWidth: true
            spacing: 6
            Dex.ClickableText
            {
                text: qsTr("Yes")
                font.underline: true
                onClicked:
                {
                    Dex.API.app.addressbookPg.model.removeContact(contactName)
                    close()
                }
            }
            Dex.ClickableText
            {
                text: qsTr("No")
                font.underline: true
                onClicked: close()
            }
        }
    }
}
