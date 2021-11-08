import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12

import QtQuick.Window 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import "../../Constants"
import "../../Settings"
import App 1.0
import Dex.Themes 1.0 as Dex

SetupPage
{
    // Override
    id: _setup

    property var    wallets: API.app.wallet_mgr.get_wallets()

    signal newWalletClicked()
    signal importWalletClicked();
    signal walletSelected(string walletName);

    image_path: Dex.CurrentTheme.bigLogoPath
    image_margin: 30

    content: ColumnLayout
    {
        id: content_column
        width: 400
        spacing: Style.rowSpacing
        RowLayout
        {
            Layout.fillWidth: true
            DexLabel
            {
                font: DexTypo.head6
                text_value: qsTr("Welcome")
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }
            DexLanguage
            {
                Layout.preferredWidth: 55
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Item { Layout.fillWidth: true }

        DefaultButton
        {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignLeft
            Layout.minimumWidth: 350
            leftPadding: 20
            text: qsTr("New Wallet")
            Layout.preferredHeight: 50
            radius: 8
            onClicked: newWalletClicked()
        }

        DefaultButton
        {
            text: qsTr("Import wallet")
            horizontalAlignment: Qt.AlignLeft
            leftPadding: 20
            radius: 8
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            onClicked: importWalletClicked()
        }

        // Wallets
        ColumnLayout
        {
            spacing: Style.rowSpacing

            visible: wallets.length > 0

            DexLabel
            {
                text_value: qsTr("My Wallets")
                font.pixelSize: Style.textSizeSmall2
                Layout.alignment: Qt.AlignHCenter
            }

            Item
            {
                height: 15
                Layout.fillWidth: true
                Rectangle
                {
                    height: 2
                    width: parent.width
                    color: Dex.CurrentTheme.accentColor
                    Rectangle
                    {
                        anchors.centerIn: parent
                        width: 9
                        height: 9
                        radius: 6
                        color: Dex.CurrentTheme.accentColor
                    }
                }
            }

            DexRectangle
            {
                id: bg

                readonly property int row_height: 40

                width: content_column.width
                Layout.minimumHeight: row_height
                Layout.preferredHeight: row_height * Math.min(wallets.length, 3)
                color: "transparent"


                DefaultListView
                {
                    id: list
                    implicitHeight: bg.Layout.preferredHeight

                    model: wallets

                    delegate: ClipRRect
                    {
                        radius: 5
                        width: bg.width
                        height: bg.row_height

                        DefaultRectangle
                        {
                            color: "transparent"
                            border.width: 0
                            anchors.fill: parent

                            Rectangle
                            {
                                height: parent.height
                                width: mouse_area.containsMouse ? parent.width : 0
                                opacity: .4
                                color: Dex.CurrentTheme.buttonColorHovered
                                visible: mouse_area.containsMouse

                                Behavior on width
                                {
                                    NumberAnimation
                                    {
                                        duration: 250
                                    }
                                }
                            }

                            DefaultMouseArea
                            {
                                id: mouse_area
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked:
                                {
                                    walletSelected(model.modelData)
                                }
                            }

                            Qaterial.ColorIcon
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                color: Dex.CurrentTheme.foregroundColor
                                source: Qaterial.Icons.account
                                iconSize: 16
                                x: 20
                            }

                            DefaultText
                            {
                                anchors.left: parent.left
                                anchors.leftMargin: 45

                                text_value: model.modelData
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: Style.textSizeSmall2
                            }
                        }

                        Item
                        {
                            anchors.right: parent.right
                            anchors.margins: 10
                            height: parent.height
                            width: 30
                            Qaterial.ColorIcon
                            {
                                source: Qaterial.Icons.delete_
                                iconSize: 18
                                anchors.centerIn: parent
                                opacity: .8
                                color: _deleteArea.containsMouse ? Dex.CurrentTheme.noColor : Dex.CurrentTheme.foregroundColor
                            }

                            DexMouseArea
                            {
                                id: _deleteArea
                                hoverEnabled: true
                                anchors.fill: parent
                                onClicked:
                                {
                                    let wallet_name = model.modelData;
                                    let dialog = app.getText({
                                        "title": qsTr("Delete") + " %1 ".arg(wallet_name) + ("wallet?"),
                                        text: qsTr("Enter password to confirm deletion of") + " %1 ".arg(wallet_name) + qsTr("wallet"),
                                        standardButtons: Dialog.Yes | Dialog.Cancel,
                                        warning: true,
                                        width: 300,
                                        iconColor: Dex.CurrentTheme.noColor,
                                        isPassword: true,
                                        placeholderText: qsTr("Type password"),
                                        yesButtonText: qsTr("Delete"),
                                        cancelButtonText: qsTr("Cancel"),
                                        onAccepted: function(text)
                                        {
                                            if (API.app.wallet_mgr.confirm_password(wallet_name, text))
                                            {
                                                API.app.wallet_mgr.delete_wallet(wallet_name);
                                                app.showText({
                                                    title: qsTr("Wallet status"),
                                                    text: "%1 ".arg(wallet_name) + qsTr("wallet deleted successfully"),
                                                    standardButtons: Dialog.Ok
                                                })
                                                _setup.wallets = API.app.wallet_mgr.get_wallets()
                                            } else
                                            {
                                                app.showText({
                                                    title: qsTr("Wallet status"),
                                                    text: "%1 ".arg(wallet_name) + qsTr("wallet password entered is incorrect"),
                                                    iconSource: Qaterial.Icons.alert,
                                                    iconColor: Dex.CurrentTheme.noColor,
                                                    warning: true,
                                                    standardButtons: Dialog.Ok
                                                })
                                            }
                                            dialog.close()
                                            dialog.destroy()
                                        }
                                    });
                                }
                            }
                        }
                    }
                }
            }
        }
        HorizontalLine { }
    }

    GaussianBlur
    {
        anchors.fill: _setup
        visible: false
        source: _setup
        radius: 21
        deviation: 2
    }
}
