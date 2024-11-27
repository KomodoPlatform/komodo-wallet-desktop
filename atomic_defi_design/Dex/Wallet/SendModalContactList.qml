// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// Project Imports
import "../Components"
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

MultipageModal
{
    id: root

    width: 600

    property string ticker: api_wallet_page.ticker
    property var selected_address: ""

    Component.onCompleted: API.app.addressbookPg.model.proxy.typeFilter = ticker
    Component.onDestruction: API.app.addressbookPg.model.proxy.typeFilter = ""

    MultipageModalContent
    {
        titleText: qsTr("Select a contact with an %1 address").arg(ticker)

        // Searchbar
        DexTextField
        {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            placeholderText: qsTr("Search for contacts...")
            onTextChanged: API.app.addressbookPg.model.proxy.searchExp = text
            Component.onDestruction: API.app.addressbookPg.model.proxy.searchExp = ""
        }

        // Contact List
        DefaultListView
        {
            id: contactListView

            Layout.fillWidth: true

            model: API.app.addressbookPg.model.proxy
            delegate: DefaultRectangle
            {
                property int addressesCount
                property var contactModel: modelData

                width: contactListView.width
                height: 30
                color: mouse_area.containsMouse ? Dex.CurrentTheme.accentColor : index % 2 === 0 ? Dex.CurrentTheme.backgroundColor : Dex.CurrentTheme.backgroundColorDeep

                Component.onCompleted:
                {
                    modelData.proxyFilter.filterType = ticker
                    addressesCount = modelData.proxyFilter.rowCount()
                }
                Component.onDestruction: contactModel.proxyFilter.typeFilter = ""

                DefaultMouseArea
                {
                    id: mouse_area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:
                    {
                        addressesView.contactModel = modelData
                        root.currentIndex = 1
                    }
                }

                DexLabel // Contact Name
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    width: parent * 0.4
                    text: modelData.name
                    elide: Qt.ElideRight
                }

                DexLabel // Contact Addresses Count
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    width: parent * 0.4
                    text: addressesCount > 1 ? qsTr("%1 addresses").arg(addressesCount) : qsTr("1 address")
                    elide: Qt.ElideRight
                }

                HorizontalLine
                {
                    width: parent.width
                    height: 2
                    anchors.bottom: parent.bottom
                }
            }
        }

        footer:
        [
            Item { Layout.fillWidth: true },
            DefaultButton // Back to Send Modal Button
            {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 280
                text: qsTr("Back")
                onClicked: close()
            },
            Item { Layout.fillWidth: true }
        ]
    }

    MultipageModalContent
    {
        id: addressesView

        readonly property var defaultContactModel:
        {
            "proxyFilter":
            {
                "filterType": ""
            },
            "name": ""
        }
        property var contactModel: defaultContactModel

        property int columnsMargin: 10
        property int nameColumnWidth: width * 0.3

        titleText: qsTr("Choose an %1 address of %2").arg(contactModel.proxyFilter.filterType).arg(contactModel.name)

        RowLayout
        {
            Layout.fillWidth: true
            spacing: 0

            DexLabel
            {
                Layout.leftMargin: addressesView.columnsMargin
                Layout.preferredWidth: addressesView.nameColumnWidth
                text: qsTr("Name")
                color: Dex.CurrentTheme.foregroundColor2
            }

            DexLabel
            {
                Layout.leftMargin: addressesView.columnsMargin
                text: qsTr("Address")
                color: Dex.CurrentTheme.foregroundColor2
            }
        }

        DefaultListView
        {
            id: addressListView

            Layout.fillWidth: true

            model: addressesView.contactModel.proxyFilter
            delegate: DefaultRectangle
            {
                width: addressListView.width
                height: 30
                color: address_mouse_area.containsMouse ? Dex.CurrentTheme.accentColor : index % 2 === 0 ? Dex.CurrentTheme.backgroundColor : Dex.CurrentTheme.backgroundColorDeep

                DefaultMouseArea
                {
                    id: address_mouse_area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:
                    {
                        selected_address = model.address_value
                        close()
                    }
                }

                DexLabel
                {
                    id: addressKeyLabel
                    width: addressesView.nameColumnWidth
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: addressesView.columnsMargin
                    text: model.address_key
                    elide: Qt.ElideRight
                }

                DexLabel
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: addressKeyLabel.right
                    anchors.leftMargin: addressesView.columnsMargin
                    anchors.right: parent.right
                    anchors.rightMargin: addressesView.columnsMargin
                    text: model.address_value
                    elide: Qt.ElideRight
                }
            }
        }

        footer:
        [
            Item { Layout.fillWidth: true },
            DefaultButton
            {
                Layout.preferredWidth: 280
                text: qsTr("Back")
                onClicked: currentIndex = 0
            },
            Item { Layout.fillWidth: true }
        ]
    }
}
