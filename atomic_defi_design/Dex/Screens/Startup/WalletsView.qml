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

    property
    var wallets: API.app.wallet_mgr.get_wallets()

    signal newWalletClicked()
    signal importWalletClicked();
    signal walletSelected(string walletName);

    image_path: Dex.CurrentTheme.bigLogoPath
    image_margin: 30

    backgroundColor: Dex.CurrentTheme.backgroundColor

    content: ColumnLayout
    {
        id: content_column
        width: 270
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
                horizontalAlignment: Label.AlignHCenter
            }
        }

        Item
        {
            Layout.fillWidth: true
        }

        GradientButton
        {
            Layout.fillWidth: true
            Layout.minimumWidth: 269
            text: qsTr("New wallet")
            Layout.preferredHeight: 40
            radius: 18
            onClicked: newWalletClicked()
        }

        OutlineButton
        {
            text: qsTr("Import wallet")
            radius: 18
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            onClicked: importWalletClicked()
        }

        // Wallets
        ColumnLayout
        {
            spacing: Style.rowSpacing

            visible: wallets.length > 0

            RowLayout
            {
                Layout.fillWidth: true
                spacing: 10
                Rectangle
                {
                    Layout.fillWidth: true
                    height: 1
                    color: Dex.CurrentTheme.floatingBackgroundColor
                    Layout.alignment: Qt.AlignVCenter
                    opacity: .5
                }
                DexLabel
                {
                    text_value: qsTr("My Wallets")
                    font.pixelSize: Style.textSizeSmall2
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Rectangle
                {
                    Layout.fillWidth: true
                    height: 1
                    color: Dex.CurrentTheme.floatingBackgroundColor
                    Layout.alignment: Qt.AlignVCenter
                    opacity: .5
                }
            }


            DexRectangle
            {
                id: bg

                readonly property int row_height: 40

                width: content_column.width
                Layout.minimumHeight: row_height
                Layout.preferredHeight: (50 * Math.min(wallets.length, 3)) + 10
                color: Dex.CurrentTheme.floatingBackgroundColor
                radius: 18


                DefaultListView
                {
                    id: list
                    implicitHeight: bg.Layout.preferredHeight
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    model: wallets

                    delegate: ClipRRect
                    {
                        radius: 18
                        width: bg.width - 20
                        height: bg.row_height

                        DefaultRectangle
                        {
                            color: "transparent"
                            border.width: 0
                            anchors.fill: parent
                            radius: 18

                            Rectangle
                            {
                                height: parent.height
                                width: parent.width
                                opacity: 1
                                color: Dex.CurrentTheme.backgroundColor
                                visible: mouse_area.containsMouse
                                radius: 18
                            }

                            DexMouseArea
                            {
                                id: mouse_area
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked:
                                {
                                    walletSelected(model.modelData)
                                }
                            }

                            Rectangle
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                x: 5
                                width: 30
                                height: width
                                radius: 18
                                color: mouse_area.containsMouse ? Dex.CurrentTheme.floatingBackgroundColor : 'transparent'
                                Qaterial.ColorIcon
                                {
                                    anchors.centerIn: parent
                                    color: Dex.CurrentTheme.foregroundColor
                                    source: Qaterial.Icons.account
                                    iconSize: 16

                                }
                            }

                            DefaultText
                            {
                                anchors.left: parent.left
                                anchors.leftMargin: 40

                                text_value: model.modelData
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: Style.textSizeSmall2
                                font.family: 'Ubuntu'
                                font.weight: Font.Medium
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
                                source: Qaterial.Icons.close
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
                                    let dialog = app.getText(
                                    {
                                        "title": qsTr("Delete") + " %1 ".arg(wallet_name) + ("wallet?"),
                                        text: qsTr("Enter password to confirm deletion of") + " %1 ".arg(wallet_name) + qsTr("wallet"),
                                        standardButtons: Dialog.Yes | Dialog.Cancel,
                                        warning: true,
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
                                                app.showText(
                                                {
                                                    title: qsTr("Wallet status"),
                                                    text: "%1 ".arg(wallet_name) + qsTr("wallet deleted successfully"),
                                                    yesButtonText: qsTr("Ok"), titleBold: true,
                                                    standardButtons: Dialog.Ok
                                                })
                                                _setup.wallets = API.app.wallet_mgr.get_wallets()
                                            }
                                            else
                                            {
                                                app.showText(
                                                {
                                                    title: qsTr("Wallet status"),
                                                    text: "%1 ".arg(wallet_name) + qsTr("wallet password is incorrect"),
                                                    warning: true,
                                                    standardButtons: Dialog.Ok, titleBold: true,
                                                    yesButtonText: qsTr("Ok"),
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


        HorizontalLine
        {}
    }

    LinksRow
    {
        Layout.alignment: Qt.AlignHCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40

        anchors.horizontalCenter: parent.horizontalCenter

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