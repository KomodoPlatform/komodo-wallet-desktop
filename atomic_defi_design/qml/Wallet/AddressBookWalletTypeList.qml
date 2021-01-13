import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Universal 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"

Qaterial.Expandable {
    id: root

    property string title

    property string type_title
    property string type: ""

    property var model

    header: Qaterial.ItemDelegate {
        id: _header

        onClicked: () => root.expanded = !root.expanded

        icon.source: General.image_path + "arrow_down.svg"

        text: title
    }

    delegate: Column {
        AddressBookWalletTypeListRow {
            enabled: type !== ""
            visible: type !== ""

            icon_source: General.coinTypeIcon(type)

            width: root.width

            name: type_title
            ticker: type_title

            onClicked: onTypeSelect(type)
        }

        Repeater {
            model: root.model

            delegate: AddressBookWalletTypeListRow {
                width: root.width

                name: model.name
                ticker: model.ticker

                onClicked: onTypeSelect(ticker)
            }
        }
    }
}
