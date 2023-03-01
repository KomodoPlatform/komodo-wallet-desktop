// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

// Project Imports
import "../Constants"
import Dex.Components 1.0 as Dex

Dex.Popup
{
    id: root

    width: 250
    height: 55

    onClosed: tagNameField.text = ""

    contentItem: Row
    {
        spacing: 4

        Dex.TextField
        {
            id: tagNameField
            width: parent.width * 0.6
            height: parent.height
            placeholderText: qsTr("Tag name")

            Dex.ToolTip
            {
                id: tagAlreadyTakenToolTip
                visible: false
                timeout: 3000
                contentItem: Dex.Text
                {
                    text_value: qsTr("Contact already has this tag.")
                }
            }
        }

        Dex.Button
        {
            width: parent.width * 0.36
            height: parent.height
            text: qsTr("+ ADD")
            onClicked:
            {
                if (tagNameField.text.length === 0)
                {
                    return
                }

                var addTagResult = contactModel.addCategory(tagNameField.text)

                if (addTagResult === false) tagAlreadyTakenToolTip.visible = true
                else root.close()
            }
        }
    }
}
