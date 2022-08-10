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

    horizontalPadding: 30
    verticalPadding: 40

    MultipageModalContent
    {
        titleText: qsTr("Confirm Exchange Details")
        title.font.pixelSize: Style.textSize2
        titleAlignment: Qt.AlignHCenter
        titleTopMargin: 10
        topMarginAfterTitle: 0
        flickMax: window.height - 450

        header: [
            RowLayout
            {
                id: dex_pair_badges

                PairItemBadge
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

                PairItemBadge
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

                DefaultText
                {
                    Layout.alignment: Qt.AlignHCenter
                    text_value: qsTr("This swap request can not be undone and is a final event!")
                }

                DefaultText
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

            width: dex_pair_badges.width - 20
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: 8

            spacing: 5

            // Fees Area
            DefaultRectangle {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredHeight: 150
                Layout.preferredWidth: parent.width - 40
                color: DexTheme.contentColorTop
                visible: !buy_sell_rpc_busy

                ColumnLayout
                {
                    anchors.centerIn: parent
                    visible: !fees_detail.visible

                    DefaultBusyIndicator
                    {
                        Layout.preferredHeight: 100
                        Layout.preferredWidth: 100
                        Layout.alignment: Qt.AlignHCenter
                        Layout.leftMargin: -15
                        Layout.rightMargin: Layout.leftMargin * 0.75
                        scale: 0.8
                    }

                    DefaultText
                    {
                        text_value: qsTr("Loading fees...")
                        Layout.bottomMargin: 8
                    }
                }

                ColumnLayout
                {
                    id: fees_detail
                    width: parent.width - 20
                    anchors.centerIn: parent
                    spacing: 6
                    visible: root.fees.hasOwnProperty('base_transaction_fees_ticker') && !API.app.trading_pg.preimage_rpc_busy

                    Repeater
                    {
                        model: root.fees.hasOwnProperty('base_transaction_fees_ticker') && !API.app.trading_pg.preimage_rpc_busy ? General.getFeesDetail(root.fees) : []
                        delegate: DefaultText
                        {
                            font.pixelSize: Style.textSizeSmall1
                            text: General.getFeesDetailText(modelData.label, modelData.fee, modelData.ticker)
                        }
                    }

                    Repeater
                    {
                        model: root.fees.hasOwnProperty('base_transaction_fees_ticker') ? root.fees.total_fees : []
                        delegate: DefaultText
                        {
                            text: General.getFeesDetailText(
                                    qsTr("<b>Total %1 fees:</b>").arg(modelData.coin),
                                    modelData.required_balance,
                                    modelData.coin)
                        }
                        Layout.alignment: Qt.AlignHCenter
                    }

                    DefaultText
                    {
                        id: errors
                        visible: text_value != ''
                        Layout.alignment: Qt.AlignHCenter
                        width: parent.width
                        horizontalAlignment: DefaultText.AlignHCenter
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
            Item
            {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: parent.width - 10
                height: childrenRect.height
                visible: !buy_sell_rpc_busy

                ColumnLayout
                {
                    id: use_custom
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    spacing: 5

                    DefaultCheckBox
                    {
                        id: enable_custom_config
                        Layout.alignment: Qt.AlignCenter
                        spacing: 2
                        boxWidth: 20
                        boxHeight: 20
                        height: 50
                        label.wrapMode: Label.NoWrap

                        text: qsTr("Use custom protection settings for incoming %1 transactions", "TICKER").arg(rel_ticker)
                    }

                    DefaultSwitch
                    {
                        id: enable_dpow_confs
                        visible: enable_custom_config.checked && config_section.is_dpow_configurable
                        checked: true
                        Layout.preferredWidth: 260
                        Layout.alignment: Qt.AlignCenter
                        mouseArea.hoverEnabled: true
                        labelWidth: 200
                        label.wrapMode: Label.NoWrap
                        label.text: qsTr("Enable Komodo dPoW security")
                        label2.text: General.cex_icon + ' <a href="https://komodoplatform.com/security-delayed-proof-of-work-dpow/">' + qsTr('Read more about dPoW') + '</a>'
                    }

                    ColumnLayout
                    {
                        height: 50
                        Layout.alignment: Qt.AlignCenter
                        spacing: 5

                        DefaultText
                        {
                            height: 16
                            Layout.alignment: Qt.AlignCenter
                            visible: !enable_custom_config.checked
                            text_value: qsTr("Security configuration")
                            font.weight: Font.Medium
                        }

                        DefaultText
                        {
                            height: 12
                            font: DexTypo.caption
                            Layout.alignment: Qt.AlignCenter
                            horizontalAlignment: Text.AlignHCenter
                            visible: !enable_custom_config.checked
                            text_value: "✅ " + (
                                config_section.is_dpow_configurable
                                ? '<a href="https://komodoplatform.com/security-delayed-proof-of-work-dpow/">'
                                + qsTr("dPoW protected") + General.cex_icon +  '</a>'
                                : qsTr("%1 confirmations for incoming %2 transactions")
                                .arg(config_section.default_config.required_confirmations || 1).arg(rel_ticker)
                            )
                        }
                    }
                }
            }

            // Configuration settings
            Item
            {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: parent.width - 10
                Layout.preferredHeight: 90
                height: childrenRect.height
                visible: !buy_sell_rpc_busy

                ColumnLayout
                {
                    id: security_config
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 60
                    spacing: 3

                    ColumnLayout
                    {
                        Layout.alignment: Qt.AlignCenter
                        spacing: 3

                        DefaultText
                        {
                            height: 30
                            Layout.alignment: Qt.AlignCenter
                            horizontalAlignment: Text.AlignHCenter
                            visible: required_confirmation_count.visible
                            text_value: qsTr("Required Confirmations") + ": " + required_confirmation_count.value
                            color: Dex.CurrentTheme.foregroundColor
                            opacity: parent.enabled ? 1 : .6
                        }

                        DefaultSlider
                        {
                            id: required_confirmation_count
                            height: 30

                            Layout.alignment: Qt.AlignCenter

                            visible: enable_custom_config.checked && (!config_section.is_dpow_configurable || !enable_dpow_confs.checked)
                            readonly property int default_confirmation_count: 3
                            stepSize: 1
                            from: 1
                            to: 5
                            live: true
                            snapMode: Slider.SnapAlways
                            value: default_confirmation_count
                        }
                    }

                    // No dPoW Warning
                    FloatingBackground
                    {
                        Layout.alignment: Qt.AlignCenter
                        width: 360
                        height: 30
                        color: Style.colorRed2
                        visible: {
                            enable_custom_config.checked && (config_section.is_dpow_configurable && !enable_dpow_confs.checked)
                        }

                        DefaultText
                        {
                            id: dpow_off_warning
                            anchors.fill: parent
                            color: Style.colorWhite0
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            text_value: Style.warningCharacter + " " + qsTr("Warning, this atomic swap is not dPoW protected!")
                        }
                    }
                }
            }

            Item
            {
                visible: buy_sell_rpc_busy
                height: config_section.height
                width: config_section.width

                DefaultBusyIndicator
                {
                    id: rpcBusyIndicator
                    anchors.fill: parent
                    anchors.centerIn: parent
                }
            }
        }

        footer:
        [
            Item { Layout.fillWidth: true },

            DefaultButton
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
