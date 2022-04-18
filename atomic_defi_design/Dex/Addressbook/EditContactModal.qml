import QtQuick 2.12
import QtQuick.Layouts 1.15

import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex
import "../Constants" as Dex

Dex.MultipageModal
{
    id: root

    property var contactModel: { "name": "", "categories": [] }

    Dex.MultipageModalContent
    {
        titleText: qsTr("Edit contact")
        titleTopMargin: 0
        titleAlignment: Qt.AlignHCenter
        contentSpacing: 24

        Dex.TextFieldWithTitle
        {
            id: contactNameInput
            title: qsTr("Contact name")
            field.placeholderText: qsTr("Enter a contact name")
            field.text: contactModel.name
            field.onTextChanged: if (field.text.length > 30) field.text = field.text.substring(0, 30)
        }

        Column
        {
            id: addressList
            property bool contactAddAddressMode: false

            Layout.fillWidth: true
            spacing: 18

            Dex.Text
            {
                text: qsTr("Address list")
            }

            Dex.ListView
            {
                visible: !addressList.contactAddAddressMode
                model: contactModel.proxyFilter
                spacing: 20
                height: contentHeight > 380 ? 380 : contentHeight
                width: parent.width

                delegate: ColumnLayout
                {
                    property var coinInfo: Dex.API.app.portfolio_pg.global_cfg_mdl.get_coin_info(address_type)

                    Row
                    {
                        spacing: 10
                        Dex.Image
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 25
                            height: 25
                            source: Dex.General.coinIcon(parent.parent.coinInfo.ticker)
                        }

                        Dex.Text
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            text: address_type
                        }

                        Dex.Text
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            text: parent.parent.coinInfo.type
                            color: Dex.Style.getCoinTypeColor(parent.parent.coinInfo.type)
                            font: Dex.DexTypo.overLine
                        }
                    }

                    Dex.Text
                    {
                        Layout.leftMargin: 30
                        text: "%1 : %2".arg(address_key).arg(address_value)
                    }
                }
            }

            Dex.Button
            {
                visible: !addressList.contactAddAddressMode
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("+ Add")
                width: 211
                height: 38
                radius: 18
                onClicked: addressList.contactAddAddressMode = true
            }

            AddAddressForm
            {
                visible: addressList.contactAddAddressMode
                contactModel: root.contactModel
                onCancel: addressList.contactAddAddressMode = false
                onAddressCreated: addressList.contactAddAddressMode = false
            }
        }

        Column
        {
            Layout.fillWidth: true
            spacing: 12

            Dex.Text
            {
                text: qsTr("Tags")
            }

            Flow
            {
                Layout.fillWidth: true

                Repeater
                {
                    model: contactModel.categories

                    Dex.Button
                    {

                    }
                }
            }

            Dex.ClickableText
            {
                text: qsTr("Add tag")
            }
        }

        footer:
        [
            Dex.Button
            {
                Layout.preferredWidth: 199
                Layout.preferredHeight: 48
                radius: 18
                text: qsTr("Close")
                onClicked: root.close()
            },

            Item { Layout.fillWidth: true },

            Dex.GradientButton
            {
                Layout.preferredWidth: 199
                Layout.preferredHeight: 48
                radius: 18
                text: qsTr("Confirm")
                onClicked:
                {
                    contactModel.name = contactNameInput.field.text
                    contactModel.save()
                    root.close()
                }
            }
        ]
    }
}
