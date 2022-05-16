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

    onOpened: nameField.forceActiveFocus()
    onClosed: nameField.text = ""

    contentItem: Row
    {
        spacing: 4

        Dex.TextField
        {
            id: nameField
            width: parent.width * 0.6
            height: parent.height
            placeholderText: qsTr("Contact name")

            Dex.ToolTip
            {
                id: nameAlreadyTakenToolTip
                visible: false
                timeout: 3000
                contentItem: Dex.Text
                {
                    text_value: qsTr("This contact name already exists.")
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
                if (nameField.text.length === 0)
                {
                    return
                }

                var createContactResult = API.app.addressbookPg.model.addContact(nameField.text)

                if (createContactResult === false) nameAlreadyTakenToolTip.visible = true
                else
                {
                    root.close()

                    let contactModelIndex = API.app.addressbookPg.model.index(API.app.addressbookPg.model.rowCount() - 1, 0)
                    editContactLoader.contactModel = API.app.addressbookPg.model.data(contactModelIndex, Qt.UserRole + 1)
                    editContactLoader.open()
                }
            }
        }
    }
}
