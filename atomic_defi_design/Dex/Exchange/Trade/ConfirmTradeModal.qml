import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import AtomicDEX.TradingError 1.0

import "../../Components"
import "../../Constants"
import ".."

import "Orders/"

import App 1.0

BasicModal {
    id: root

    width: 650

    readonly property var fees: API.app.trading_pg.fees

    ModalContent {
        title: qsTr("Confirm Exchange Details")

        OrderContent {
            Layout.topMargin: 25
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: Layout.leftMargin
            height: 120
            Layout.alignment: Qt.AlignHCenter

            details: ({
                    base_coin: base_ticker,
                    rel_coin: rel_ticker,
                    base_amount: base_amount,
                    rel_amount: rel_amount,

                    order_id: '',
                    date: '',
                   })
            in_modal: true
        }

        Column {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 500
            PriceLineSimplified {
                width: 500
            }
        }
        

        HorizontalLine {
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.fillWidth: true
        }

        Column {
            Layout.preferredWidth: 500
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10

            ColumnLayout {
                id: warning_texts
                width: 500

                DexLabel {
                    Layout.alignment: Qt.AlignLeft

                    text_value: qsTr("This swap request can not be undone and is a final event!")
                }

                DexLabel {
                    Layout.alignment: Qt.AlignLeft

                    text_value: qsTr("This transaction can take up to 60 mins - DO NOT close this application!")
                    font.pixelSize: Style.textSizeSmall4
                }
            }
        }

        Item  {
            Layout.preferredWidth: 500
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: feesColumn.height + 10
            opacity: .7
            Column {
                id: feesColumn
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                  model: fees.total_fees
                  delegate: DefaultText {
                    visible: true
                    text: qsTr("Total %1 fees: %2 (%3)").arg(modelData.coin).arg(parseFloat(modelData.required_balance).toFixed(8) / 1).arg(General.getFiatText(modelData.required_balance, modelData.coin, false))
                  }
                  anchors.horizontalCenter: parent.horizontalCenter
                }
                Item {width: 1; height: 10}
                DefaultText {
                    id: errors
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    horizontalAlignment: DefaultText.AlignHCenter
                    font: DexTypo.caption
                    color: DexTheme.redColor

                    text_value: General.getTradingError(
                                    last_trading_error,
                                    curr_fee_info,
                                    base_ticker,
                                    rel_ticker, left_ticker, right_ticker)
                }
            }
        }


        ColumnLayout {
            id: config_section

            readonly property var default_config: API.app.trading_pg.get_raw_mm2_coin_cfg(rel_ticker)

            readonly property bool is_dpow_configurable: config_section.default_config.requires_notarization || false
            Layout.bottomMargin: 10
            Layout.alignment: Qt.AlignHCenter

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                visible: !enable_custom_config.checked

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter
                    text_value: qsTr("Security configuration")
                    font.weight: Font.Medium
                }


                DefaultText {
                    Layout.alignment: Qt.AlignHCenter
                    text_value: "✅ " + (config_section.is_dpow_configurable ? qsTr("dPoW protected") :
                                qsTr("%1 confirmations for incoming %2 transactions").arg(config_section.default_config.required_confirmations || 1).arg(rel_ticker))
                }

                DefaultText {
                    visible: config_section.is_dpow_configurable
                    Layout.alignment: Qt.AlignHCenter
                    text_value: General.cex_icon + ' <a href="https://komodoplatform.com/security-delayed-proof-of-work-dpow/">' + qsTr('Read more about dPoW') + '</a>'
                    font.pixelSize: Style.textSizeSmall2
                }
            }

            // Enable custom config
            DexCheckBox {
                Layout.alignment: Qt.AlignHCenter
                id: enable_custom_config

                text: qsTr("Use custom protection settings for incoming %1 transactions", "TICKER").arg(rel_ticker)
            }

            // Configuration settings
            ColumnLayout {
                id: custom_config
                visible: enable_custom_config.checked

                Layout.alignment: Qt.AlignHCenter

                // dPoW configuration switch
                DefaultSwitch {
                    id: enable_dpow_confs
                    Layout.alignment: Qt.AlignHCenter

                    visible: config_section.is_dpow_configurable
                    checked: true
                    text: qsTr("Enable Komodo dPoW security")
                }

                DefaultText {
                    visible: enable_dpow_confs.visible && enable_dpow_confs.enabled
                    Layout.alignment: Qt.AlignHCenter
                    text_value: General.cex_icon + ' <a href="https://komodoplatform.com/security-delayed-proof-of-work-dpow/">' + qsTr('Read more about dPoW') + '</a>'
                    font.pixelSize: Style.textSizeSmall2
                }

                // Normal configuration settings
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    visible: !config_section.is_dpow_configurable || !enable_dpow_confs.checked
                    enabled: !config_section.is_dpow_configurable || !enable_dpow_confs.checked

                    HorizontalLine {
                        Layout.topMargin: 10
                        Layout.bottomMargin: 10
                        Layout.fillWidth: true
                    }

                    DefaultText {
                        Layout.preferredHeight: 10
                        Layout.alignment: Qt.AlignHCenter
                        text_value: qsTr("Required Confirmations") + ": " + required_confirmation_count.value
                        color: DexTheme.foregroundColor
                        opacity: parent.enabled ? 1 : .6
                    }

                    DexSlider {
                        id: required_confirmation_count
                        readonly property int default_confirmation_count: 3
                        Layout.alignment: Qt.AlignHCenter
                        stepSize: 1
                        from: 1
                        to: 5
                        live: true
                        snapMode: Slider.SnapAlways
                        value: default_confirmation_count
                    }
                }
            }

            FloatingBackground {
                visible: enable_custom_config.visible && enable_custom_config.enabled && enable_custom_config.checked &&
                          (config_section.is_dpow_configurable && !enable_dpow_confs.checked)
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10

                color: Style.colorRed2

                width: dpow_off_warning.width + 20
                height: dpow_off_warning.height + 20

                ColumnLayout {
                    id: dpow_off_warning
                    anchors.centerIn: parent

                    DefaultText {
                        Layout.alignment: Qt.AlignHCenter
                        color: Style.colorWhite0
                        text_value: Style.warningCharacter + " " + qsTr("Warning, this atomic swap is not dPoW protected!")
                    }
                }
            }
            DefaultBusyIndicator {
                visible: buy_sell_rpc_busy
                Layout.alignment: Qt.AlignCenter
            }
        }
        HorizontalLine {
            Layout.fillWidth: true
        }
        // Buttons
        footer: [
            Item {
                Layout.fillWidth: true
            },
            DexAppButton {
                text: qsTr("Cancel")
                padding: 17
                leftPadding: 45
                rightPadding: 45
                radius: 18
                onClicked: {
                    //fees = []
                    root.close()
                }
            },
            Item {
                Layout.fillWidth: true
            },
            DexGradientAppButton {
                text: qsTr("Confirm")
                padding: 17
                leftPadding: 45
                rightPadding: 45

                radius: 18
                enabled: !buy_sell_rpc_busy && last_trading_error === TradingError.None
                onClicked: {
                    trade({
                            enable_custom_config: enable_custom_config.checked,
                            is_dpow_configurable: config_section.is_dpow_configurable,
                            enable_dpow_confs: enable_dpow_confs.checked,
                            required_confirmation_count: required_confirmation_count.value,
                          }, config_section.default_config)
                }
            },
            Item {
                Layout.fillWidth: true
            }
        ]
    }
}
