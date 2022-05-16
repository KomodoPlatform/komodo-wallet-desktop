import QtQuick 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal 2.15 //> Universal.accent

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex
import Dex.Components 1.0 as Dex
import "../Constants" as Dex

Dex.Rectangle
{
    property var     contactModel

    // Edition mode variables
    property bool    editionMode: false
    property string  addressType
    property string  addressKey
    property string  addressValue

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
                        33, addressType)
            addressKeyField.text = addressKey
            addressValueField.text = addressValue
            console.log(indexLis)
        }
    }

    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: 21
        spacing: 17

        Dex.ComboBox
        {
            id: addressTypeComboBox

            property var currentItem: Dex.API.app.portfolio_pg.portfolio_mdl.portfolio_proxy_mdl.get(currentIndex)

            Layout.preferredWidth: 458
            Layout.preferredHeight: 44
            model: Dex.API.app.portfolio_pg.portfolio_mdl.portfolio_proxy_mdl
            dropDownMaxHeight: 150
            textRole: "ticker"

            delegate: Qaterial.ItemDelegate
            {
                id: _delegate

                Universal.accent: Dex.CurrentTheme.comboBoxDropdownItemHighlightedColor
                width: addressTypeComboBox.width
                highlighted: addressTypeComboBox.highlightedIndex === index

                contentItem: Row
                {
                    height: 36
                    spacing: 10

                    Dex.Image
                    {
                        width: 25
                        height: 25
                        anchors.verticalCenter: parent.verticalCenter
                        source: Dex.General.coinIcon(ticker)
                    }

                    Dex.Text
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        text: name
                    }

                    Dex.Text
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.type
                        color: Dex.Style.getCoinTypeColor(model.type)
                        font: Dex.DexTypo.overLine
                    }
                }
            }

            contentItem: Item
            {
                Row
                {
                    anchors.left: parent.left
                    anchors.leftMargin: 13
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Dex.Image
                    {
                        width: 25
                        height: 25
                        anchors.verticalCenter: parent.verticalCenter
                        source: Dex.General.coinIcon(addressTypeComboBox.currentItem.ticker)
                    }

                    Dex.Text
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        text: addressTypeComboBox.currentItem.name
                    }

                    Dex.Text
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        text: addressTypeComboBox.currentItem.type
                        color: Dex.Style.getCoinTypeColor(addressTypeComboBox.currentItem.type)
                        font: Dex.DexTypo.overLine
                    }
                }
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
                        Dex.API.app.wallet_pg.convert_address(addressValueField.text, addressTypeComboBox.currentText, API.app.wallet_pg.validate_address_data.to_address_format);
                    else
                        Dex.API.app.wallet_pg.validate_address(addressValueField.text, addressTypeComboBox.currentText)
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
