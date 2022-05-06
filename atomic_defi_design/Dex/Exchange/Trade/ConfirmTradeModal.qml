import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial

import AtomicDEX.TradingError 1.0
import "../../Components"
import "../../Constants"
import ".."
import "Orders/"
import App 1.0
import Dex.Themes 1.0 as Dex

MultipageModal
{
    id: root
    readonly property var fees: API.app.trading_pg.fees

    horizontalPadding: 60
    verticalPadding: 40

    MultipageModalContent
    {
        titleText: qsTr("Confirm Exchange Details")
        title.font.pixelSize: Style.textSize2
        titleAlignment: Qt.AlignHCenter
        titleTopMargin: 10
        topMarginAfterTitle: 0
        Layout.preferredHeight: window.height - 50

        header: [
            RowLayout
            {
                id: dex_pair_badges

                DexPairItemBadge
                {
                    source: General.coinIcon(!base_ticker ? atomic_app_primary_coin : base_ticker)
                    ticker: base_ticker
                    fullname: General.coinName(base_ticker)
                    amount: base_amount
                }

                Qaterial.Icon
                {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    color: Dex.CurrentTheme.foregroundColor
                    icon: Qaterial.Icons.swapHorizontal
                }

                DexPairItemBadge
                {
                    source: General.coinIcon(!rel_ticker ? atomic_app_primary_coin : rel_ticker)
                    ticker: rel_ticker
                    fullname: General.coinName(rel_ticker)
                    amount: rel_amount
                }
            },

            PriceLineSimplified
            {
                id: price_line
                Layout.fillWidth: true
            },

            ColumnLayout
            {
                id: warnings_text
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                DexLabel
                {
                    Layout.alignment: Qt.AlignHCenter
                    text_value: qsTr("This swap request can not be undone and is a final event!")
                }

                DexLabel
                {
                    id: warnings_tx_time_text
                    Layout.alignment: Qt.AlignHCenter
                    text_value: qsTr("This transaction can take up to 60 mins - DO NOT close this application!")
                    font.pixelSize: Style.textSizeSmall4
                }
            }
        ]

        ColumnLayout
        {
            id: config_section

            readonly property var default_config: API.app.trading_pg.get_raw_mm2_coin_cfg(rel_ticker)
            readonly property bool is_dpow_configurable: config_section.default_config.requires_notarization || false

            width: parent.width - 60
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: 10

            spacing: 10


            DexRectangle {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredHeight: fees_detail.height + 20
                Layout.preferredWidth: parent.width - 60
                color: DexTheme.contentColorTop
                visible: root.fees.hasOwnProperty('base_transaction_fees_ticker') && !API.app.trading_pg.preimage_rpc_busy

                ColumnLayout
                {
                    id: fees_detail
                    width: parent.width - 20
                    anchors.centerIn: parent
                    spacing: 8

                    Repeater
                    {
                        model: root.fees.hasOwnProperty('base_transaction_fees_ticker') && !API.app.trading_pg.preimage_rpc_busy ? General.getFeesDetail(root.fees) : []
                        delegate: DexLabel
                        {
                            font.pixelSize: Style.textSizeSmall1
                            text: General.getFeesDetailText(modelData.label, modelData.fee, modelData.ticker)
                        }
                    }

                    Repeater
                    {
                        model: root.fees.hasOwnProperty('base_transaction_fees_ticker') ? root.fees.total_fees : []
                        delegate: DexLabel
                        {
                            text: General.getFeesDetailText(
                                    qsTr("<b>Total %1 fees:</b>").arg(modelData.coin),
                                    modelData.required_balance,
                                    modelData.coin)
                        }
                        Layout.alignment: Qt.AlignHCenter
                    }

                    DexLabel
                    {
                        id: errors
                        visible: text_value != ''
                        Layout.alignment: Qt.AlignHCenter
                        width: parent.width
                        horizontalAlignment: DexLabel.AlignHCenter
                        font: DexTypo.caption
                        color: Dex.CurrentTheme.noColor
                        text_value: General.getTradingError(
                                        last_trading_error,
                                        curr_fee_info,
                                        base_ticker,
                                        rel_ticker, left_ticker, right_ticker)
                    }

                }
            }

            // Custom config checkbox
            Item {
                Layout.preferredHeight: use_custom.height
                Layout.preferredWidth: use_custom.width
                Layout.alignment: Qt.AlignCenter

                ColumnLayout
                {
                    id: use_custom
                    spacing: 8

                    DexCheckBox
                    {
                        id: enable_custom_config
                        Layout.alignment: Qt.AlignCenter

                        spacing: 2
                        boxWidth: 20
                        boxHeight: 20
                        label.wrapMode: Label.NoWrap

                        text: qsTr("Use custom protection settings for incoming %1 transactions", "TICKER").arg(rel_ticker)
                    }

                    // Custom config settings
                    Item
                    {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 280
                        Layout.alignment: Qt.AlignCenter
                        visible: enable_custom_config.checked && config_section.is_dpow_configurable

                        DexSwitch
                        {
                            id: enable_dpow_confs
                            labelWidth: 220
                            anchors.verticalCenter: parent.verticalCenter
                            label.wrapMode: Label.NoWrap

                            checked: true
                            label.text: qsTr("Enable Komodo dPoW security")
                            mouseArea.hoverEnabled: true
                        }
                    }
                }
            }

            // Custom Configuration settings
            Item
            {
                Layout.preferredHeight: custom_config.height
                Layout.preferredWidth: custom_config.width
                Layout.alignment: Qt.AlignCenter
                visible: enable_custom_config.checked

                ColumnLayout
                {
                    id: custom_config
                    Layout.alignment: Qt.AlignCenter

                    // Normal configuration settings
                    ColumnLayout
                    {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        visible: !config_section.is_dpow_configurable || !enable_dpow_confs.checked
                        enabled: !config_section.is_dpow_configurable || !enable_dpow_confs.checked
                        spacing: 8


                        DexLabel
                        {
                            Layout.preferredHeight: 10
                            Layout.alignment: Qt.AlignHCenter
                            text_value: qsTr("Required Confirmations") + ": " + required_confirmation_count.value
                            color: DexTheme.foregroundColor
                            opacity: parent.enabled ? 1 : .6
                        }

                        DexSlider
                        {
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

                    FloatingBackground
                    {
                        visible: enable_custom_config.visible && enable_custom_config.enabled && enable_custom_config.checked &&
                                  (config_section.is_dpow_configurable && !enable_dpow_confs.checked)
                        Layout.alignment: Qt.AlignHCenter

                        color: Style.colorRed2
                        width: dpow_off_warning.width + 20
                        height: dpow_off_warning.height + 20

                        ColumnLayout
                        {
                            id: dpow_off_warning
                            anchors.centerIn: parent

                            DexLabel
                            {
                                Layout.alignment: Qt.AlignHCenter
                                text_value: Style.warningCharacter + " " + qsTr("Warning, this atomic swap is not dPoW protected!")
                            }
                        }
                    }
                }
            }

            // Custom config
            Item {
                Layout.preferredHeight: security_config.height
                Layout.preferredWidth: security_config.width
                Layout.alignment: Qt.AlignCenter
                Layout.fillHeight: true

                ColumnLayout
                {
                    id: security_config
                    spacing: 8

                    DexLabel
                    {
                        Layout.alignment: Qt.AlignCenter
                        visible: !enable_custom_config.checked
                        text_value: qsTr("Security configuration")
                        font.weight: Font.Medium
                    }

                    DexLabel
                    {
                        Layout.alignment: Qt.AlignCenter
                        horizontalAlignment: Text.AlignHCenter
                        visible: !enable_custom_config.checked
                        text_value: "✅ " + (config_section.is_dpow_configurable ? qsTr("dPoW protected") :
                                    qsTr("%1 confirmations for incoming %2 transactions").arg(config_section.default_config.required_confirmations || 1).arg(rel_ticker))
                    }
                    DexLabel
                    {
                        visible: config_section.is_dpow_configurable && enable_dpow_confs.enabled
                        Layout.alignment: Qt.AlignHCenter
                        text_value: General.cex_icon + ' <a href="https://komodoplatform.com/security-delayed-proof-of-work-dpow/">' + qsTr('Read more about dPoW') + '</a>'
                        font.pixelSize: Style.textSizeSmall2
                    }
                }
            }

            DexBusyIndicator
            {
                visible: buy_sell_rpc_busy
                Layout.alignment: Qt.AlignCenter
            }
        }

        footer:
        [
            Item { Layout.fillWidth: true },

            DexAppButton
            {
                text: qsTr("Cancel")
                padding: 10
                leftPadding: 45
                rightPadding: 45
                radius: 10
                onClicked: root.close()
            },

            Item { Layout.fillWidth: true },

            DexGradientAppButton
            {
                text: qsTr("Confirm")
                padding: 10
                leftPadding: 45
                rightPadding: 45
                radius: 10
                enabled: !buy_sell_rpc_busy && last_trading_error === TradingError.None
                onClicked:
                {
                    trade({ enable_custom_config: enable_custom_config.checked,
                            is_dpow_configurable: config_section.is_dpow_configurable,
                            enable_dpow_confs: enable_dpow_confs.checked,
                            required_confirmation_count: required_confirmation_count.value, },
                          config_section.default_config)
                }
            },

            Item { Layout.fillWidth: true }
        ]
    }
}
