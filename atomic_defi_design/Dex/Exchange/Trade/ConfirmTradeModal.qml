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
            readonly property var fees: API.app.trading_pg.fees
            readonly property bool is_dpow_configurable: config_section.default_config.requires_notarization || false

            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            spacing: 10

            Item
            {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: fees_detail.height + 10
                opacity: .7
                visible: {
                    console.log(config_section.fees)
                    config_section.fees
                }

                Column
                {
                    id: fees_detail
                    anchors.verticalCenter: parent.verticalCenter
                    visible: config_section.base_transaction_fees_ticker && !API.app.trading_pg.preimage_rpc_busy

                    Repeater
                    {
                        model: config_section.fees.base_transaction_fees_ticker && !API.app.trading_pg.preimage_rpc_busy ? General.getFeesDetail(fees) : []
                        delegate: DexLabel
                        {
                            font.pixelSize: Style.textSizeSmall1
                            text: General.getFeesDetailText(modelData.label, modelData.fee, modelData.ticker)
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Item {width: 1; height: 10}

                    Repeater
                    {
                        model: config_section.fees.base_transaction_fees_ticker ? config_section.fees.total_fees : []
                        delegate: DexLabel
                        {
                            text: General.getFeesDetailText(
                                    qsTr("<b>Total %1 fees:</b>").arg(modelData.coin),
                                    modelData.required_balance,
                                    modelData.coin)
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Item {width: 1; height: 10}
                }

                DexLabel
                {
                    id: errors
                    anchors.horizontalCenter: parent.horizontalCenter
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

            RowLayout
            {
                spacing: 0
                Layout.topMargin: 10
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignHCenter

                // Enable custom config
                DexCheckBox
                {
                    id: enable_custom_config

                    spacing: 2
                    boxWidth: 20
                    boxHeight: 20
                    labelWidth: parent.width - 40
                    label.wrapMode: Label.NoWrap
                    label.horizontalAlignment: Text.AlignHCenter
                    label.verticalAlignment: Text.AlignVCenter

                    text: qsTr("Use custom protection settings for incoming %1 transactions", "TICKER").arg(rel_ticker)
                }
            }

            ColumnLayout
            {
                Layout.alignment: Qt.AlignHCenter
                visible: !enable_custom_config.checked

                DexLabel
                {
                    Layout.alignment: Qt.AlignHCenter
                    text_value: qsTr("Security configuration")
                    font.weight: Font.Medium
                }

                DexLabel
                {
                    Layout.alignment: Qt.AlignHCenter
                    text_value: "✅ " + (config_section.is_dpow_configurable ? qsTr("dPoW protected") :
                                qsTr("%1 confirmations for incoming %2 transactions").arg(config_section.default_config.required_confirmations || 1).arg(rel_ticker))
                }

                DexLabel
                {
                    visible: config_section.is_dpow_configurable
                    Layout.alignment: Qt.AlignHCenter
                    text_value: General.cex_icon + ' <a href="https://komodoplatform.com/security-delayed-proof-of-work-dpow/">' + qsTr('Read more about dPoW') + '</a>'
                    font.pixelSize: Style.textSizeSmall2
                }
            }

            // Configuration settings
            ColumnLayout
            {
                id: custom_config
                visible: enable_custom_config.checked

                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true

                // dPoW configuration switch
                DexSwitch
                {
                    id: enable_dpow_confs
                    Layout.alignment: Qt.AlignHCenter

                    visible: config_section.is_dpow_configurable
                    checked: true
                    text: qsTr("Enable Komodo dPoW security")
                }

                DexLabel
                {
                    visible: enable_dpow_confs.visible && enable_dpow_confs.enabled
                    Layout.alignment: Qt.AlignHCenter
                    text_value: General.cex_icon + ' <a href="https://komodoplatform.com/security-delayed-proof-of-work-dpow/">' + qsTr('Read more about dPoW') + '</a>'
                    font.pixelSize: Style.textSizeSmall2
                }

                // Normal configuration settings
                ColumnLayout
                {
                    Layout.alignment: Qt.AlignHCenter
                    visible: !config_section.is_dpow_configurable || !enable_dpow_confs.checked
                    enabled: !config_section.is_dpow_configurable || !enable_dpow_confs.checked

                    HorizontalLine
                    {
                        Layout.topMargin: 10
                        Layout.bottomMargin: 10
                        Layout.fillWidth: true
                    }

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
