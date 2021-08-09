// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

// Deps Imports
import Qaterial 1.0 as Qaterial

// Project Imports
import "../Components"
import "../Constants"
import App 1.0

BasicModal {
    id: root

    property var contactModel

    function trySend(wallet_type, address) {
        // Checks if the selected wallet type is a coin type instead of a coin.
        if (API.app.portfolio_pg.global_cfg_mdl.is_coin_type(wallet_type)) {
            send_selector.coin_type = wallet_type
            send_selector.address = address
            send_selector.open()
        }

        // Checks if the coin is currently enabled.
        else if (!API.app.portfolio_pg.is_coin_enabled(wallet_type)) {
            enable_coin_modal.coin_name = wallet_type
            enable_coin_modal.open()
        }

        // Checks if the coin has balance.
        else if (parseFloat(API.app.get_balance(wallet_type)) === 0) {
            cannot_send_modal.open()
        }

        // If the coin has balance and is enabled, opens the send modal.
        else {
            API.app.wallet_pg.ticker = wallet_type
            send_modal.address = address
            send_modal.open()
        }
    }

    width: 700

    onClosed: contactModel.reload()

    ModalContent {
        Layout.topMargin: 5
        Layout.fillWidth: true

        title: qsTr("Edit contact")

        // Contact name section
        TextFieldWithTitle {
            id: name_input
            width: 30
            title: qsTr("Contact Name")
            field.placeholderText: qsTr("Enter a contact name")
            field.text: contactModel.name
            field.onTextChanged: {
                const max_length = 50
                if (field.text.length > max_length)
                    field.text = field.text.substring(0, max_length)
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        // Wallets Information
        ColumnLayout {
            Layout.fillWidth: true

            // Title
            TitleText { text: qsTr("Address List") }

            DefaultTextField {
                Layout.topMargin: 10
                Layout.fillWidth: true

                placeholderText: qsTr("Search for an address entry.")

                onTextChanged: contactModel.proxy_filter.search_expression = text
                Component.onDestruction: contactModel.proxy_filter.search_expression = ""
            }

            // Addresses Table
            TableView
            {
                id: walletInfoTable

                property int _typeColWidth: 90
                property int _keyColWidth: 100
                property int _addressColWidth: 320
                property int _actionsColWidth: 60

                model: contactModel.proxy_filter

                Layout.topMargin: 15
                Layout.fillWidth: true

                backgroundVisible: false
                frameVisible: false

                headerDelegate: RowLayout
                {
                    Layout.preferredWidth: styleData.column === 0 ? walletInfoTable._typeColWidth :
                                           styleData.column === 1 ? walletInfoTable._keyColWidth :
                                           styleData.column === 2 ? walletInfoTable._addressColWidth :
                                                                    walletInfoTable._actionsColWidth

                    Item
                    {
                        Layout.fillWidth: true
                        height: 20

                        

                        DefaultText
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            text: styleData.value
                        }

                        VerticalLine
                        {
                            visible: styleData.column !== 3
                            Layout.alignment: Qt.AlignRight
                            Layout.fillHeight: true
                        }
                    }
                }

                rowDelegate: DefaultRectangle
                {
                    height: 37; radius: 0
                    color: styleData.selected ? DexTheme.accentLightColor4: styleData.alternate ? DexTheme.accentDarkColor4 : 'transparent'
                }

                TableViewColumn // Type Column
                {
                    width: walletInfoTable._typeColWidth

                    role: "address_type"
                    title: qsTr("Type")

                    resizable: false
                    movable: false

                    delegate: RowLayout
                    {
                        DexLabel
                        {
                            Layout.preferredWidth: parent.width - 10
                            Layout.leftMargin: 3
                            text: styleData.row >= 0 ? styleData.value : ""
                            font.pixelSize: Style.textSizeSmall3
                            elide: Text.ElideRight
                        }

                        VerticalLine
                        {
                            Layout.alignment: Qt.AlignRight
                            Layout.fillHeight: true
                        }
                    }
                }

                TableViewColumn // Key Column
                {
                    width: walletInfoTable._keyColWidth

                    role: "address_key"
                    title: qsTr("Key")

                    resizable: false
                    movable: false

                    delegate: RowLayout
                    {
                        DefaultText
                        {
                            Layout.preferredWidth: parent.width - 10
                            Layout.leftMargin: 3
                            text: styleData.row >= 0 ? styleData.value : ""
                            font.pixelSize: Style.textSizeSmall3
                            elide: Text.ElideRight
                        }

                        VerticalLine
                        {
                            Layout.alignment: Qt.AlignRight
                            Layout.fillHeight: true
                        }
                    }
                }

                TableViewColumn
                {
                    width: walletInfoTable._addressColWidth

                    role: "address_value"
                    title: qsTr("Address")

                    resizable: false
                    movable: false

                    delegate: RowLayout
                    {
                        DexLabel
                        {
                            Layout.preferredWidth: parent.width - 10
                            Layout.leftMargin: 3
                            text: styleData.row >= 0 ? styleData.value : ""
                            font.pixelSize: Style.textSizeSmall3
                            elide: Text.ElideRight
                        }

                        VerticalLine
                        {
                            Layout.alignment: Qt.AlignRight
                            Layout.fillHeight: true
                        }
                    }
                }

                TableViewColumn // Actions Column
                {
                    width: walletInfoTable._actionsColWidth
                    title: qsTr("Actions")

                    resizable: false
                    movable: false

                    delegate: Row
                    {
                        spacing: 0

                        Qaterial.OutlineButton // Edit Address Button
                        {
                            implicitHeight: 35
                            implicitWidth: 35

                            outlined: false

                            Qaterial.ColorIcon
                            {
                                anchors.centerIn: parent
                                source:  Qaterial.Icons.leadPencil
                                color: DexTheme.foregroundColor
                                opacity: .8
                            }

                            onClicked:
                            {
                                address_edition_modal.walletType = model.address_type;
                                address_edition_modal.key = model.address_key;
                                address_edition_modal.value = model.address_value;
                                address_edition_modal.open();
                            }
                        }

                        Qaterial.OutlineButton // Delete Button
                        {
                            implicitHeight: 35
                            implicitWidth: 35 
                            outlined: false

                            Qaterial.ColorIcon
                            {
                                anchors.centerIn: parent
                                source:  Qaterial.Icons.trashCan
                                color: DexTheme.redColor
                                opacity: .8
                            }
                            onClicked:
                            {
                                removeAddressEntryModal.addressKey = model.address_key;
                                removeAddressEntryModal.addressType = model.address_type;
                                removeAddressEntryModal.contactModel = contactModel;
                                removeAddressEntryModal.open();
                            }
                        }

                        Qaterial.OutlineButton // Copy Clipboard Button
                        {
                            implicitHeight: 35
                            implicitWidth: 35

                            outlined: false
                            Qaterial.ColorIcon
                            {
                                anchors.centerIn: parent
                                source:  Qaterial.Icons.contentCopy
                                color: DexTheme.foregroundColor
                                opacity: .8
                            }

                            onClicked: API.qt_utilities.copy_text_to_clipboard(model.address_value)
                        }

                        Qaterial.OutlineButton // Send Button
                        {
                            implicitHeight: 35
                            implicitWidth: 35

                            outlined: false
                            Qaterial.ColorIcon
                            {
                                anchors.centerIn: parent
                                source:  Qaterial.Icons.send
                                color: DexTheme.foregroundColor
                                opacity: .8
                            }

                            onClicked: trySend(model.address_type, model.address_value)
                        }
                    }
                }
            }

            RowLayout {
                PrimaryButton { // New Address Button
                    text: qsTr("New Address")

                    onClicked: address_creation_modal.open();
                }
            }

            ModalLoader {
                id: address_creation_modal
                sourceComponent: AddressBookAddContactAddressModal {
                    contactModel: root.contactModel
                }
            }

            ModalLoader {
                id: address_edition_modal

                property string walletType
                property string key
                property string value

                onLoaded: {
                    item.oldWalletType = walletType
                    item.walletType = walletType

                    item.oldKey = key
                    item.key = key

                    item.oldValue = value
                    item.value = value
                }

                sourceComponent: AddressBookAddContactAddressModal {
                    contactModel: root.contactModel
                    isEdition: true
                }
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        // Categories Section Title
        TitleText {
            text: qsTr("Tags")
        }

        // Categories (Tags) List
        Flow {
            Layout.fillWidth: true
            spacing: 10
            Repeater {
                id: category_repeater
                model: contactModel.categories

                DexAppButton {
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: 4
                    border.color: backgroundColor
                    iconSource: Qaterial.Icons.closeOctagon
                    text: modelData
                    onClicked: contactModel.remove_category(modelData);
                }
            }

            // Category adding form opening button
            DexAppButton {
                Layout.leftMargin: 10
                width: height
                text: qsTr("+")

                onClicked: add_category_modal.open()
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        // Actions on current contact
        RowLayout {
            Layout.alignment: Qt.AlignBottom | Qt.AlignRight
            Layout.rightMargin: 15

            PrimaryButton { // Validate (Save) Changes
                text: qsTr("Confirm")
                onClicked: {
                    contactModel.name = name_input.field.text
                    contactModel.save()
                    root.close();
                }
            }

            DefaultButton { // Cancel Changes
                text: qsTr("Cancel")
                onClicked: root.close()
            }
        }

        // Wallet Type List Modal
        ModalLoader {
            id: wallet_type_list_modal

            property string selected_wallet_type: ""

            sourceComponent: AddressBookWalletTypeListModal {
                onSelected_wallet_typeChanged: wallet_type_list_modal.selected_wallet_type = selected_wallet_type
            }
        }

        // Enable Coin Modal
        ModalLoader {
            property string coin_name

            id: enable_coin_modal

            sourceComponent: BasicModal {
                ModalContent {
                    Layout.fillWidth: true
                    title: qsTr("Enable " + coin_name)

                    DefaultText {
                        text: qsTr("The selected address belongs to a disabled coin, you need to enabled it before sending.")
                    }

                    Row {
                        // Enable button
                        PrimaryButton {
                            text: qsTr("Enable")

                            onClicked: {
                                API.app.enable_coin(coin_name)
                                enable_coin_modal.close()
                            }
                        }

                        // Cancel button
                        DefaultButton {
                            Layout.rightMargin: 5
                            text: qsTr("Cancel")

                            onClicked: enable_coin_modal.close()
                        }
                    }
                }
            }
        }

        // Send Selector modal
        ModalLoader {
            id: send_selector

            property string coin_type
            property string address

            onLoaded: {
                item.coin_type = coin_type
                item.address = address
            }

            sourceComponent: AddressBookSendWalletSelector {}
        }

        // Send Modal
        ModalLoader {
            property string address

            id: send_modal

            onLoaded: item.address_field.text = address

            sourceComponent: SendModal {
                address_field.enabled: false
            }
        }

        // Cannot Send Modal
        ModalLoader {
            id: cannot_send_modal

            sourceComponent: BasicModal {
                ModalContent {
                    title: qsTr("Cannot send to this address")

                    DefaultText {
                        text: qsTr("Your balance is empty")
                    }

                    DefaultButton {
                        text: qsTr("Ok")

                        onClicked: cannot_send_modal.close()
                    }
                }
            }
        }

        // Remove address entry modal
        ModalLoader
        {
            id: removeAddressEntryModal

            property var    contactModel
            property string addressKey
            property string addressType

            sourceComponent: BasicModal
            {
                width: 250
                ModalContent
                {
                    title: qsTr("Remove address ?")

                    RowLayout
                    {
                        DexButton { text: qsTr("Yes"); onClicked: { contactModel.remove_address_entry(addressType, addressKey); close(); } }
                        DexButton { text: qsTr("No"); onClicked: close() }
                    }
                }
            }
        }

        // Category (Tag) Adding Modal
        ModalLoader {
            id: add_category_modal

            onLoaded: item.contactModel = root.contactModel

            sourceComponent: AddressBookNewContactCategoryModal {}
        }
    }
}
