import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Universal 2.15

import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"
import App 1.0

Qaterial.Expandable
{
    id: _root

    property string title

    property string type_title
    property string type: ""
    property string typeIcon: type

    property var model

    header: Qaterial.ItemDelegate
    {
        id: _header

        icon.source: General.image_path + "arrow_down.svg"
        DexLabel {
            anchors.verticalCenter: parent.verticalCenter
            text: title
            leftPadding: 60
            font.bold: true
        }

        onClicked: () => _root.expanded = !_root.expanded
    }

    delegate: Column
    {
        AddressBookWalletTypeListRow
        {
            enabled: type !== ""
            visible: type !== ""

            icon_source: General.coinTypeIcon(typeIcon)

            width: _root.width

            name: type_title
            ticker: type_title

            onClicked: onTypeSelect(type)
        }

        Repeater
        {
            model: _root.model

            delegate: AddressBookWalletTypeListRow
            {
                width: _root.width

                name: model.name
                ticker: model.ticker

                onClicked: onTypeSelect(ticker)
            }
        }
    }
}
