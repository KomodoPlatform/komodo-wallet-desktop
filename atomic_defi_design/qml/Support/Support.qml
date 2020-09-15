import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

Item {
    id: root

    function reset() {

    }

    function onOpened() {

    }

    DefaultFlickable {
        id: layout_background

        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: anchors.leftMargin
        anchors.bottomMargin: anchors.leftMargin

        contentWidth: width
        contentHeight: content_layout.height

        ColumnLayout {
            id: content_layout
            width: parent.width
            spacing: 40

            Item {
                Layout.topMargin: parent.spacing
                Layout.fillWidth: true
                Layout.preferredHeight: discord_icon.height

                RowLayout {
                    id: row_layout
                    spacing: 10
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    LinkIcon {
                        link: "https://komodoplatform.com/discord"
                        source: General.image_path + "icon-discord.png"
                    }

                    LinkIcon {
                        link: "https://twitter.com/atomicDEX"
                        source: General.image_path + "icon-twitter.png"
                    }

                    LinkIcon {
                        link: "https://support.komodoplatform.com/support/home"
                        source: General.image_path + "icon-support.png"
                    }

//                    LinkIcon {
//                        link: "mailto:support@komodoplatform.com"
//                        source: General.image_path + "icon-email.png"
//                    }
                }


                MouseArea {
                    id: changelog_button

                    anchors.centerIn: parent
                    width: column_layout.width
                    height: column_layout.height
                    hoverEnabled: true

                    onClicked: update_modal.open()

                    ColumnLayout {
                        id: column_layout
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter

                            Circle {
                                Layout.alignment: Qt.AlignVCenter

                                color: Qt.lighter(update_modal.update_needed ? Style.colorOrange : Style.colorGreen, changelog_button.containsMouse ? Style.hoverLightMultiplier : 1.0)
                            }

                            DefaultText {
                                Layout.alignment: Qt.AlignVCenter
                                text_value: API.get().settings_pg.empty_string + (update_modal.update_needed ? qsTr("Update available") : qsTr("Up to date"))
                                color: changelog_text.color
                            }
                        }

                        DefaultText {
                            Layout.alignment: Qt.AlignHCenter
                            text_value: API.get().settings_pg.empty_string + (General.version_string)
                            font.pixelSize: Style.textSizeSmall3
                            color: changelog_text.color
                        }

                        DefaultText {
                            id: changelog_text
                            Layout.alignment: Qt.AlignHCenter
                            text_value: API.get().settings_pg.empty_string + (General.cex_icon + ' ' + qsTr('Changelog'))
                            font.pixelSize: Style.textSizeSmall2

                            color: Qt.lighter(Style.colorWhite4, changelog_button.containsMouse ? Style.hoverLightMultiplier : 1.0)
                        }
                    }
                }

                DefaultButton {
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: API.get().settings_pg.empty_string + (qsTr("Open Logs Folder"))
                    onClicked: openLogsFolder()
                }
            }

            HorizontalLine {
                Layout.fillWidth: true
            }

            DefaultText {
                Layout.alignment: Qt.AlignHCenter
                text_value: API.get().settings_pg.empty_string + (qsTr("Frequently Asked Questions"))
                font.pixelSize: Style.textSize2
            }











            // FAQ Lines
            FAQLine {
                title: API.get().settings_pg.empty_string + (qsTr("Do you store my private keys?"))
                text: API.get().settings_pg.empty_string + (qsTr("No! atomicDEX is non-custodial. We never store any sensitive data, including your private keys, seed phrases, or PIN. All of these are only stored on the user’s device and never leave it. You are in full control of your assets."))
            }

            FAQLine {
                title: API.get().settings_pg.empty_string + (qsTr("How is trading on atomicDEX different from trading on other DEXs?"))
                text: API.get().settings_pg.empty_string + (qsTr("Other DEXs generally only allow you to trade assets that are based on a single blockchain network, use proxy tokens, and only allow placing a single order with the same funds.

atomicDEX enables you to natively trade across two different blockchain networks without proxy tokens. You can also place multiple orders with the same funds, for example selling 0.1 BTC for KMD, QTUM, or VRSC -- the first that fills automatically cancels all other orders."))
            }

            FAQLine {
                title: API.get().settings_pg.empty_string + (qsTr("How long does each atomic swap take?"))
                text: API.get().settings_pg.empty_string + (qsTr("Several factors determine the processing time for each swap, the block time of the traded assets (Bitcoin is typically the slowest), network congestion, and your selected network fee (e.g. amount of gas you pay for ETH or ERC-20 swaps)."))
            }

            FAQLine {
                title: API.get().settings_pg.empty_string + (qsTr("Do I need to be online for the duration of the swap?"))
                text: API.get().settings_pg.empty_string + (qsTr("Yes. You must remain connected to the internet and have your app running to successfully complete each atomic swap (very short cuts in connectivity are usually fine). Otherwise, your trade will automatically be canceled."))
            }

            FAQLine {
                title: API.get().settings_pg.empty_string + (qsTr("How are the fees on atomicDEX calculated?"))
                text: API.get().settings_pg.empty_string + (qsTr("There are two fee categories to consider when trading on atomicDEX.

1. atomicDEX charges a 0.15% trading fee for taker orders, and maker orders have zero fees.
2. Both makers and takers will need to pay normal transaction fees when making atomic swaps.

Network fees can vary greatly depending on your selected trading pair. This is why atomicDEX supports advanced fee management. We give you the option to choose between quicker swaps or lower fees!"))
            }

            FAQLine {
                title: API.get().settings_pg.empty_string + (qsTr("Do you provide user support?"))
                text: API.get().settings_pg.empty_string + (qsTr("Yes! Unlike most open source blockchain projects, atomicDEX offers 24/7 support. Join our Discord, we are happy to help!"))
            }

            FAQLine {
                title: API.get().settings_pg.empty_string + (qsTr("Do you have country restrictions?"))
                text: API.get().settings_pg.empty_string + (qsTr("No! atomicDEX is fully decentralized. It is not possible to limit user access by any third party."))
            }

            FAQLine {
                title: API.get().settings_pg.empty_string + (qsTr("Who is behind atomicDEX?"))
                text: API.get().settings_pg.empty_string + (qsTr("atomicDEX is developed by the Komodo team. Komodo is one of the most established blockchain projects working on innovative solutions like atomic swaps, Delayed Proof-of-Work, and an interoperable multi-chain architecture."))
            }

            FAQLine {
                title: API.get().settings_pg.empty_string + (qsTr("Is it possible to develop my own white-label exchange on atomicDEX?"))
                text: API.get().settings_pg.empty_string + (qsTr("Absolutely! You can read our developer documentation for more details or contact us with your partnership inquiries. Have a specific technical question? The atomicDEX developer community is always ready to help!"))
            }

            FAQLine {
                title: API.get().settings_pg.empty_string + (qsTr("Which devices can I use atomicDEX on?"))
                text: API.get().settings_pg.empty_string + (qsTr("atomicDEX is available for mobile on both Android and iPhone, and for desktop on Windows, Linux and Mac operating systems."))
            }
        }
    }
}
