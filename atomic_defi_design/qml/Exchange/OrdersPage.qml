import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import ".."

Item {
    id: root

    readonly property date default_min_date: new Date("2019-01-01")
    readonly property date default_max_date: new Date(new Date().setDate(new Date().getDate() + 30))

    property var list_model: API.app.orders_mdl
    property var list_model_proxy: API.app.orders_mdl.orders_proxy_mdl
    property int page_index

    property alias title: order_list.title
    //property alias empty_text: order_list.empty_text
    property alias items: order_list.items

    property bool is_history: false

    property string recover_funds_result: '{}'

    function onRecoverFunds(order_id) {
        const result = API.app.recover_fund(order_id)
        console.log("Refund result: ", result)
        recover_funds_result = result
        recover_funds_modal.open()
    }

//    function inCurrentPage() {
//        return  exchange.inCurrentPage() &&
//                exchange.current_page === page_index
//    }

    function applyDateFilter() {
        list_model_proxy.filter_minimum_date = min_date.date

        if(max_date.date < min_date.date)
            max_date.date = min_date.date

        list_model_proxy.filter_maximum_date = max_date.date
    }

    function applyTickerFilter() {
        list_model_proxy.set_coin_filter(combo_base.currentValue + "/" + combo_rel.currentValue)
    }

    function applyFilter() {
        applyDateFilter()
        applyTickerFilter()
    }

    Component.onCompleted: {
        list_model_proxy.is_history = root.is_history
        applyFilter()
        list_model_proxy.apply_all_filtering()
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        anchors.fill: parent
        spacing: 15

        // Bottom part
        Item {
            id: orders_settings
            property bool displaySetting: false
            Layout.fillWidth: true
            Layout.preferredHeight: displaySetting? 80 : 30
            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: 150
                }
            }

            Rectangle {
                width: parent.width
                height: orders_settings.displaySetting? 50 : 10
                Behavior on height {
                    NumberAnimation {
                        duration: 150
                    }
                }
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -15
                visible: false//orders_settings.height>75
                color: Style.colorTheme5
            }

            Row {
                x: 5
                y: 0
                spacing: -10
                //anchors.verticalCenter: parent.verticalCenter
                Qaterial.OutlineButton {
                    icon.source: Qaterial.Icons.filter
                    text: "Filter"
                    foregroundColor: Qaterial.Colors.white
                    anchors.verticalCenter: parent.verticalCenter
                    outlinedColor: Style.colorTheme5
                    onClicked: orders_settings.displaySetting = !orders_settings.displaySetting
                }

            }
            Row {
                anchors.right: parent.right
                y: 0
                rightPadding: 5
                //anchors.verticalCenter: parent.verticalCenter
                Qaterial.OutlineButton {
                    icon.source: Qaterial.Icons.close
                    text: "Cancel All"
                    foregroundColor: Qaterial.Colors.pink
                    anchors.verticalCenter: parent.verticalCenter
                    outlinedColor: Style.colorTheme5
                    onClicked: API.app.trading_pg.cancel_order(list_model_proxy.get_filtered_ids())
                }
            }
            RowLayout {
                visible: orders_settings.height>75
                width: parent.width-20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -15
                spacing: 10
                DefaultComboBox {
                    id: combo_base
                    model: API.app.portfolio_pg.global_cfg_mdl.all_proxy
                    onCurrentValueChanged: applyFilter()
                    width: 150
                    height: 100
                    valueRole: "ticker"
                    textRole: 'ticker'
                    editable: true
                }
                Qaterial.ColorIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qaterial.Icons.swapHorizontal
                }

                DefaultComboBox {
                    id: combo_rel
                    model: combo_base.model
                    onCurrentValueChanged: applyFilter()
                    width: 150
                    height: 100
                    valueRole: "ticker"
                    textRole: 'ticker'
                    editable: true
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Qaterial.TextFieldDatePicker {
                    id: min_date
                    title: qsTr("From")
                    from: default_min_date
                    to: default_max_date
                    date: default_min_date
                    onAccepted: applyDateFilter()
                    Layout.preferredWidth: 130
                }

                Qaterial.TextFieldDatePicker {
                    id: max_date
                    enabled: min_date.enabled
                    title: qsTr("To")
                    from: min_date.date
                    to: default_max_date
                    date: default_max_date
                    onAccepted: applyDateFilter()
                    Layout.preferredWidth: 130
                }

            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: parent.spacing

            OrderList {
                id: order_list
                items: list_model
                is_history: root.is_history
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

        }

        ModalLoader {
            id: order_modal
            sourceComponent: OrderModal {}
        }
    }


    ModalLoader {
        id: recover_funds_modal
        sourceComponent: LogModal {
            header: qsTr("Recover Funds Result")
            field.text: General.prettifyJSON(recover_funds_result)

            onClosed: recover_funds_result = "{}"
        }
    }
}

