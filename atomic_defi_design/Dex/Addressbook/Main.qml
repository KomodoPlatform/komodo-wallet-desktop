// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

import Qaterial 1.0 as Qaterial

// Project Imports
import Dex.Components 1.0 as Dex
import "../Components" as Dex
import Dex.Themes 1.0 as Dex
import "../Constants" as Dex
import "../Wallet" as Wallet

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

                    textField.onTextChanged: Dex.API.app.addressbookPg.model.proxy.searchExp = textField.text
                    Component.onDestruction: Dex.API.app.addressbookPg.model.proxy.searchExp = ""
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

                property color _tagBgColor: index % 2 !== 0 ? Dex.CurrentTheme.innerBackgroundColor : Dex.CurrentTheme.backgroundColor

                padding: 10
                color: index % 2 === 0 ? Dex.CurrentTheme.innerBackgroundColor : Dex.CurrentTheme.backgroundColor
                width: contactTable.width

                header: Item
                {
                    height: 56
                    width: expandable.width

                    Dex.DefaultMouseArea
                    {
                        anchors.fill: parent
                        onClicked: expandable.isExpanded = !expandable.isExpanded
                    }

                    Row
                    {
                        width: parent.width * 0.3
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

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

                    Flow
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        x: parent.width * 0.3
                        width: parent.width * 0.57
                        spacing: 17

                        Repeater
                        {
                            model: modelData.categories.slice(0, 6)

                            delegate: Dex.Rectangle
                            {
                                width: tagLabel.width > 73 ? 83 : tagLabel.width + 10
                                height: 21
                                radius: 20
                                color: expandable._tagBgColor

                                Dex.MouseArea
                                {
                                    anchors.fill: parent
                                    onClicked: searchbar.textField.text = modelData
                                }

                                Dex.Text
                                {
                                    id: tagLabel
                                    width: 70
                                    anchors.centerIn: parent
                                    text: modelData
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }

                    Row
                    {
                        spacing: 45
                        width: 160
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 2
                        Dex.ClickableText
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            font: Dex.DexTypo.body2
                            text: qsTr("Edit")
                            onClicked:
                            {
                                editContactLoader.contactModel = modelData
                                editContactLoader.open()
                            }
                        }
                        Dex.ClickableText
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            font: Dex.DexTypo.body2
                            text: qsTr("Delete")
                            onClicked: Dex.API.app.addressbookPg.model.removeContact(modelData.name)
                        }
                    }
                }

                content: Item
                {
                    height: noAddressLabel.visible ? 50 : addressList.height
                    width: contactTable.width

                    Dex.DexListView
                    {
                        id: addressList

                        visible: model.rowCount() > 0
                        x: 30
                        model: modelData.proxyFilter
                        width: parent.width - 40
                        implicitHeight: contentHeight > 240 ? 240 : contentHeight
                        spacing: 18

                        delegate: Item
                        {
                            property var coinInfo: Dex.API.app.portfolio_pg.global_cfg_mdl.get_coin_info(address_type)

                            width: addressList.width
                            height: 30

                            Row
                            {
                                anchors.verticalCenter: parent.verticalCenter
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

                            Row
                            {
                                x: parent.width * 0.25
                                spacing: 3

                                Dex.Text
                                {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "%1 : %2".arg(address_key).arg(address_value)
                                }


                                Dex.Button
                                {
                                    width: 25
                                    height: 25
                                    iconSource: Qaterial.Icons.contentCopy
                                    color: "transparent"
                                    onClicked:
                                    {
                                        Dex.API.qt_utilities.copy_text_to_clipboard(address_value)
                                        app.notifyCopy(qsTr("Address Book"), qsTr("address copied to clipboard"))
                                    }
                                }

                                Dex.Button
                                {
                                    width: 25
                                    height: 25
                                    iconSource: Qaterial.Icons.sendOutline
                                    color: "transparent"
                                    onClicked:
                                    {
                                        Dex.API.app.wallet_pg.ticker = address_type
                                        sendModalLoader.address = address_value
                                        sendModalLoader.open()
                                    }
                                }
                            }
                        }
                    }

                    Dex.Text
                    {
                        id: noAddressLabel
                        height: 20
                        x: 30
                        y: 15
                        visible: addressList.model.rowCount() === 0
                        text: qsTr("This contact does not have any registered address.")
                    }
                }
            }
        }
    }

    Dex.ModalLoader
    {
        id: editContactLoader

        property var contactModel

        onLoaded: item.contactModel = contactModel

        sourceComponent: EditContactModal { }
    }

    Dex.ModalLoader
    {
        id: sendModalLoader

        property string address

        onLoaded: item.address_field.text = address

        sourceComponent: Wallet.SendModal
        {
            address_field.enabled: false
        }
    }
}
