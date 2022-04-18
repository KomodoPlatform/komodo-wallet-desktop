// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

// Project Imports
import Dex.Components 1.0 as Dex
import "../Components" as Dex
import Dex.Themes 1.0 as Dex
import "../Constants" as Dex

Item
{
    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: 30

        spacing: 32

        Row
        {
            Layout.fillWidth: true

            Column
            {
                width: parent.width * 0.5
                spacing: 34

                Dex.Text
                {
                    text: qsTr("Address Book")
                    font: Dex.DexTypo.head5
                }

                Dex.SearchField
                {
                    id: searchbar

                    width: 206
                    height: 42
                    textField.placeholderText: qsTr("Search contact")

                    textField.onTextChanged: addressbookPg.model.proxy.searchExp = textField.text
                    Component.onDestruction: addressbookPg.model.proxy.searchExp = ""
                }
            }

            Row
            {
                width: parent.width * 0.5
                layoutDirection: Qt.RightToLeft

                Dex.GradientButton
                {
                    width: 213
                    height: 48.51
                    radius: 18
                    text: qsTr("+ NEW CONTACT")

                    onClicked: newContactPopup.open()

                    NewContactPopup
                    {
                        id: newContactPopup
                    }
                }
            }
        }

        // Contact table header
        Row
        {
            Layout.fillWidth: true
            Layout.topMargin: 30

            Dex.Text
            {
                width: parent.width * 0.3
                text: qsTr("Name")
                font: Dex.DexTypo.head8
                leftPadding: 18
            }

            Dex.Text
            {
                text: qsTr("Tags")
                font: Dex.DexTypo.head8
                leftPadding: 18
            }
        }

        Dex.DefaultListView
        {
            id: contactTable

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: Dex.API.app.addressbookPg.model.proxy

            delegate: Dex.Expandable
            {
                id: expandable

                padding: 12
                color: index % 2 === 0 ? Dex.CurrentTheme.innerBackgroundColor : Dex.CurrentTheme.backgroundColor
                width: contactTable.width

                header: Row
                {
                    height: 66
                    width: expandable.width
                    spacing: 0

                    Row
                    {
                        width: parent.width * 0.3
                        height: parent.height
                        spacing: 8

                        Dex.UserIcon
                        {
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Dex.Text
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                        }

                        Dex.Arrow
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            up: expandable.isExpanded
                        }
                    }


                    Dex.Text
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * 0.57
                        visible: modelData.categories.length === 0
                        text: qsTr("No tags")
                    }

                    Flow
                    {
                        width: parent.width * 0.57

                        Repeater
                        {
                            model: modelData.categories.slice(0, 6)

                            delegate: Dex.Rectangle
                            {
                                width: 83
                                height: 21
                            }
                        }
                    }

                    Row
                    {
                        spacing: 45
                        anchors.verticalCenter: parent.verticalCenter
                        Dex.ClickableText
                        {
                            font: Dex.DexTypo.body2
                            text: qsTr("Edit")
                            onClicked:
                            {
                                editContactLoader.item.contactModel = modelData
                                editContactLoader.item.open()
                            }
                        }
                        Dex.ClickableText
                        {
                            font: Dex.DexTypo.body2
                            text: qsTr("Delete")
                            onClicked: Dex.API.app.addressbookPg.model.removeContact(modelData.name)
                        }
                    }
                }
            }
        }

        Loader
        {
            id: editContactLoader
            sourceComponent: EditContactModal { }
        }
    }
}
