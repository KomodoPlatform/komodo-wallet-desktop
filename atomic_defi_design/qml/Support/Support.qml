import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

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
                        id: discord_icon
                        link: "https://komodoplatform.com/discord"
                        source: General.image_path + "icon-discord.png"
                    }

                    LinkIcon {
                        link: "https://twitter.com/AtomicDEX"
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


                DefaultMouseArea {
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
                                text_value: API.app.settings_pg.empty_string + (update_modal.update_needed ? qsTr("Update available") : qsTr("Up to date"))
                                color: changelog_text.color
                            }
                        }

                        DefaultText {
                            Layout.alignment: Qt.AlignHCenter
                            text_value: API.app.settings_pg.empty_string + (General.version_string)
                            font.pixelSize: Style.textSizeSmall3
                            color: changelog_text.color
                        }

                        DefaultText {
                            id: changelog_text
                            Layout.alignment: Qt.AlignHCenter
                            text_value: API.app.settings_pg.empty_string + (General.cex_icon + ' ' + qsTr('Changelog'))
                            font.pixelSize: Style.textSizeSmall2

                            color: Qt.lighter(Style.colorWhite4, changelog_button.containsMouse ? Style.hoverLightMultiplier : 1.0)
                        }
                    }
                }

                DefaultButton {
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: API.app.settings_pg.empty_string + (qsTr("Open Logs Folder"))
                    onClicked: openLogsFolder()
                }
            }

            HorizontalLine {
                Layout.fillWidth: true
            }

            DefaultText {
                Layout.alignment: Qt.AlignHCenter
                text_value: API.app.settings_pg.empty_string + (qsTr("Frequently Asked Questions"))
                font.pixelSize: Style.textSize2
            }











            // FAQ Lines
            FAQLine {
                title: API.app.settings_pg.empty_string + (qsTr("Do you store my private keys?"))
                text: API.app.settings_pg.empty_string + (qsTr("No! AtomicDEX is non-custodial. We never store any sensitive data, including your private keys, seed phrases, or PIN. This data is  only stored on the user’s device and never leaves it. You are in full control of your assets."))
            }

            FAQLine {
                title: API.app.settings_pg.empty_string + (qsTr("How is trading on AtomicDEX different from trading on other DEXs?"))
                text: API.app.settings_pg.empty_string + (qsTr("Other DEXs generally only allow you to trade assets that are based on a single blockchain network, use proxy tokens, and only allow placing a single order with the same funds.

AtomicDEX enables you to natively trade across two different blockchain networks without proxy tokens. You can also place multiple orders with the same funds. For example, you can sell 0.1 BTC for KMD, QTUM, or VRSC — the first order that fills automatically cancels all other orders."))
            }

            FAQLine {
                title: API.app.settings_pg.empty_string + (qsTr("How long does each atomic swap take?"))
                text: API.app.settings_pg.empty_string + (qsTr("Several factors determine the processing time for each swap. The block time of the traded assets depends on each network (Bitcoin typically being the slowest) Additionally, the user can customize security preferences. For example,  (you can ask AtomicDEX to consider a KMD transaction as final after just 3 confirmations which makes the swap time shorter compared to waiting for a [notarization] (https://komodoplatform.com/security-delayed-proof-of-work-dpow/)."))
            }

            FAQLine {
                title: API.app.settings_pg.empty_string + (qsTr("Do I need to be online for the duration of the swap?"))
                text: API.app.settings_pg.empty_string + (qsTr("Yes. You must remain connected to the internet and have your app running to successfully complete each atomic swap (very short breaks in connectivity are usually fine). Otherwise, there is risk of trade cancellation if you are a maker, and risk of loss of funds if you are a taker. The atomic swap protocol requires both participants to stay online and monitor the involved blockchains for the process to stay atomic."))
            }

            FAQLine {
                title: API.app.settings_pg.empty_string + (qsTr("How are the fees on AtomicDEX calculated?"))
                text: API.app.settings_pg.empty_string + (qsTr("There are two fee categories to consider when trading on AtomicDEX.

1. AtomicDEX charges approximately 0.13% (1/777 of trading volume but not lower than 0.0001) as the trading fee for taker orders, and maker orders have zero fees.
2. Both makers and takers will need to pay normal network fees to the involved blockchains when making atomic swap transactions.

Network fees can vary greatly depending on your selected trading pair."))
            }

            FAQLine {
                title: API.app.settings_pg.empty_string + (qsTr("Do you provide user support?"))
                text: API.app.settings_pg.empty_string + (qsTr("Yes! AtomicDEX offers support through the [Komodo Discord server](https://komodoplatform.com/discord). The team and the community are always happy to help!"))
            }

            FAQLine {
                title: API.app.settings_pg.empty_string + (qsTr("Do you have country restrictions?"))
                text: API.app.settings_pg.empty_string + (qsTr("No! AtomicDEX is fully decentralized. It is not possible to limit user access by any third party."))
            }

            FAQLine {
                title: API.app.settings_pg.empty_string + (qsTr("Who is behind AtomicDEX?"))
                text: API.app.settings_pg.empty_string + (qsTr("AtomicDEX is developed by the Komodo team. Komodo is one of the most established blockchain projects working on innovative solutions like atomic swaps, Delayed Proof of Work, and an interoperable multi-chain architecture."))
            }

            FAQLine {
                title: API.app.settings_pg.empty_string + (qsTr("Is it possible to develop my own white-label exchange on AtomicDEX?"))
                text: API.app.settings_pg.empty_string + (qsTr("Absolutely! You can read our developer documentation for more details or contact us with your partnership inquiries. Have a specific technical question? The AtomicDEX developer community is always ready to help!"))
            }

            FAQLine {
                title: API.app.settings_pg.empty_string + (qsTr("Which devices can I use AtomicDEX on?"))
                text: API.app.settings_pg.empty_string + (qsTr("AtomicDEX is available for mobile on both Android and iPhone, and for desktop on Windows, Mac, and Linux operating systems."))
            }
        }
    }
}
