import QtQuick 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex
import "../Components" as Dex
import "../Constants" as Dex

Dex.Rectangle
{
    id: root

    property var     contactModel

    // Edition mode variables
    property bool    editionMode: false
    property string  addressType
    property string  addressKey
    property string  addressValue

    // Return the asset type that will be used in the backend to validate the address
    function getTypeForAddressChecker(addressType)
    {
        switch (addressType)
        {
            case "QRC-20":      return "QTUM";
            case "BEP-20":      return "BNB";
            case "ERC-20":      return "ETH";
            case "Smart Chain": return "KMD";
            case "SLP":         return "BCH";
        }

        let coinInfo = Dex.API.app.portfolio_pg.global_cfg_mdl.get_coin_info(addressType);
        if (coinInfo.has_parent_fees_ticker)
            return coinInfo.fees_ticker;
        return addressType
    }

    signal cancel()
    signal addressCreated()

    width: 500
    height: 302
    radius: 10

    onVisibleChanged:
    {
        if (!visible)
        {
            // Resets data when address is added/edited.
            addressTypeComboBox.currentIndex = 0
            addressKeyField.text = ""
            addressValueField.text = ""
            editionMode = false
            addressType = ""
            addressKey = ""
            addressValue = ""
        }
        else if (editionMode)
        {
            // Feeds form with the data we are currently editing.
            var indexLis =
                    Dex.API.app.portfolio_pg.portfolio_mdl.match(
                        Dex.API.app.portfolio_pg.portfolio_mdl.index(0, 0),
                        Qt.UserRole + 1, addressType)
            //addres
            addressKeyField.text = addressKey
            addressValueField.text = addressValue
        }
    }

    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: 21
        spacing: 17

        RowLayout
        {
            Layout.preferredWidth: 458
            Layout.preferredHeight: 44

            AddressTypeSelector
            {
                id: addressTypeComboBox
                Layout.fillWidth: true
                Layout.fillHeight: true
                showAssetStandards: useStandardsCheckBox.checked
            }

            Dex.DefaultCheckBox
            {
                id: useStandardsCheckBox
                Layout.preferredWidth: 150
                text: qsTr("Use standard network address")
            }
        }

        Dex.TextField
        {
            id: addressKeyField
            Layout.preferredWidth: 458
            Layout.preferredHeight: 44
            placeholderText: qsTr("Label")

            Dex.ToolTip
            {
                id: addressKeyAlreadyExistsToolTip
                contentItem: Dex.Text { text_value: qsTr("This key already exists.") }
            }
        }

        Dex.TextField
        {
            id: addressValueField
            Layout.preferredWidth: 458
            Layout.preferredHeight: 44
            placeholderText: qsTr("Address")
        }

        Dex.Text
        {
            id: invalidAddressValueLabel
            color: Dex.CurrentTheme.noColor
            wrapMode: Dex.Text.Wrap
        }

        RowLayout
        {
            Layout.topMargin: 10
            Layout.fillWidth: true

            Dex.Button
            {
                Layout.preferredWidth: 116
                Layout.preferredHeight: 38
                radius: 18
                text: qsTr("Cancel")
                onClicked: cancel()
            }

            Item { Layout.fillWidth: true }

            Dex.GradientButton
            {
                property bool isConvertMode: Dex.API.app.wallet_pg.validate_address_data.convertible ?? false

                enabled: addressKeyField.length > 0 && addressValueField.length > 0 && !Dex.API.app.wallet_pg.validate_address_busy
                Layout.preferredWidth: 116
                Layout.preferredHeight: 38
                radius: 18
                text: isConvertMode ? qsTr("Convert") : editionMode ? qsTr("Edit") : qsTr("Add")
                onClicked:
                {
                    if (isConvertMode)
                        Dex.API.app.wallet_pg.convert_address(addressValueField.text, root.getTypeForAddressChecker(addressTypeComboBox.currentText), API.app.wallet_pg.validate_address_data.to_address_format);
                    else
                        Dex.API.app.wallet_pg.validate_address(addressValueField.text, root.getTypeForAddressChecker(addressTypeComboBox.currentText))
                }
            }
        }
    }

    Connections
    {
        target: Dex.API.app.wallet_pg

        function onConvertAddressBusyChanged()
        {
            if (Dex.API.app.wallet_pg.convert_address_busy) // Currently converting entered address
            {
                return
            }

            addressValueField.text = API.app.wallet_pg.converted_address
            API.app.wallet_pg.validate_address_data = {}
            invalidAddressValueLabel.text = ""
        }

        function onValidateAddressBusyChanged()
        {
            if (Dex.API.app.wallet_pg.validate_address_busy) // Currently checking entered address
            {
                return
            }

            if (!Dex.API.app.wallet_pg.validate_address_data.is_valid) // Entered address is invalid.
            {
                invalidAddressValueLabel.text = Dex.API.app.wallet_pg.validate_address_data.reason
                return
            }

            if (editionMode) // Removes old address entry before if we are in edition mode.
            {
                contactModel.removeAddressEntry(addressType, addressKey);
            }

            var createAddressResult = contactModel.addAddressEntry(addressTypeComboBox.currentText, addressKeyField.text, addressValueField.text);
            if (createAddressResult === true)
            {
                addressCreated()
            }
            else
            {
                addressKeyAlreadyExistsToolTip.visible = true
            }
        }
    }
}
