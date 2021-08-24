import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0

import App 1.0

import Qaterial 1.0 as Qaterial

import "../../../Components"

// Content
Item {
    property
    var details
    property bool in_modal: false

    readonly property bool is_placed_order: !details ? false :
        details.order_id !== ''

    RowLayout {
        width: 500
        height: 66
        anchors.centerIn: parent
        spacing: 23
        DexRectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: DexTheme.contentColorTop
            RowLayout {
                width: parent.width - 40
                height: 50
                anchors.centerIn: parent
                spacing: 23
                DefaultImage {
                    id: base_icon
                    source: General.coinIcon(!details ? atomic_app_primary_coin :
                        details.base_coin)
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 35
                    Layout.alignment: Qt.AlignVCenter
                }
                DexLabel {
                    id: base_amount
                    text_value: !details ? "" :
                                           "<b><font color='" +DexTheme.getCoinColor(details.base_coin) + "'>" + details.base_coin + "</font></b>" + "    %1".arg(General.coinName(details.base_coin))+ "<br>" + General.formatCrypto("", details.base_amount, details.base_coin).split(" ")[1]
                    font: DexTypo.body2

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    privacy: is_placed_order
                    opacity: .9
                }
            }
        }

        Qaterial.Icon {
            color: DexTheme.foregroundColor
            icon: Qaterial.Icons.swapHorizontal
            Layout.alignment: Qt.AlignVCenter
        }

        DexRectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: DexTheme.contentColorTop
            RowLayout {
                width: parent.width - 40
                height: 50
                anchors.centerIn: parent
                spacing: 23
                DefaultImage {
                    id: rel_icon
                    source: General.coinIcon(!details ? atomic_app_primary_coin :
                        details.rel_coin)
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 35
                    Layout.alignment: Qt.AlignVCenter
                }
                DexLabel {
                    id: rel_amount
                    text_value: !details ? "" : "<b><font color='" + DexTheme.getCoinColor(details.rel_coin)+"'>" + details.rel_coin + "</font></b>     %1 <br>".arg(General.coinName(details.rel_coin)) + General.formatCrypto("", details.rel_amount, details.rel_coin).split(" ")[1]
                    font: DexTypo.body2

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    privacy: is_placed_order
                    opacity: .9
                }
            }
        }
    }
}
