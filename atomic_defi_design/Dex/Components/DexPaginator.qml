import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../Constants" as Constants
import App 1.0
import Dex.Themes 1.0 as Dex

RowLayout
{
    id: root

    spacing: 4

    property var pageSize: Constants.API.app.orders_mdl.nb_pages
    property var currentValue: Constants.API.app.orders_mdl.current_page

    property alias itemsPerPageComboBox: itemsPerPageComboBox

    function refreshBtn()
    {
        currentValue = Constants.API.app.orders_mdl.current_page
        var model = []
        if (pageSize < 10) {
            for (var i = 0; i < pageSize; i++) {
                model.push({
                    number: i + 1,
                    selected: currentValue === i + 1
                })
            }
        } else {

            [1, 2].map(v => model.push({
                number: v,
                selected: currentValue === v
            }));

            model.push({
                number: currentValue - 2 > 1 + 3 ? -1 : 1 + 2,
                selected: currentValue === 3
            });

            for (var k = Math.max(1 + 3, currentValue - 2); k <= Math.min(pageSize - 3, currentValue + 2); k++) {
                model.push({
                    number: k,
                    selected: currentValue === k
                });
            }

            model.push({
                number: currentValue + 2 < pageSize - 3 ? -1 : pageSize - 2,
                selected: currentValue === pageSize - 2
            });
            [pageSize - 1, pageSize].map(v => model.push({
                number: v,
                selected: currentValue === v
            }));
        }
        btnGroup.model = model
    }

    onPageSizeChanged:
    {
        currentValue = 1
        if (pageSize < 1) {
            pageSize = 1
        }
        refreshBtn()
    }

    DexComboBox
    {
        id: itemsPerPageComboBox

        readonly property int item_count: Constants.API.app.orders_mdl.limit_nb_elements
        readonly property
        var options: [5, 10, 25, 50, 100, 200]

        Layout.preferredWidth: (root.width / 100) * 14
        Layout.maximumWidth: 62
        Layout.preferredHeight: 35
        Layout.alignment: Qt.AlignLeft

        model: options
        currentIndex: options.indexOf(item_count)
        onCurrentValueChanged: Constants.API.app.orders_mdl.limit_nb_elements = currentValue
    }

    DexText
    {
        Layout.preferredWidth: (root.width / 100) * 16
        Layout.leftMargin: 20
        Layout.alignment: Qt.AlignLeft
        font.pixelSize: 12
        text: qsTr("items per page")
        color: Dex.CurrentTheme.foregroundColor2
    }

    Item
    {
        Layout.fillWidth: true
    }

    PaginationButton
    {
        Layout.preferredWidth: (root.width / 100) * 5
        Layout.preferredHeight: width
        radius: 20
        opacity: enabled ? 1 : .5
        Qaterial.ColorIcon
        {
            anchors.centerIn: parent
            iconSize: 14
            color: Dex.CurrentTheme.foregroundColor
            source: Qaterial.Icons.skipPreviousOutline
        }
        enabled: currentValue > 1
        onClicked: {
            --Constants.API.app.orders_mdl.current_page
            refreshBtn()
        }
    }


    Repeater
    {
        id: btnGroup
        model:
        [{
            number: 1,
            selected: true
        }]
        delegate: PaginationButton
        {
            text: modelData.number === -1 ? "..." : ("" + modelData.number)
            radius: 30
            Layout.preferredWidth: (root.width / 100) * 4
            Layout.preferredHeight: width
            Layout.alignment: Qt.AlignVCenter
            color: modelData.number === currentValue ? 'transparent' : Dex.CurrentTheme.buttonColorEnabled
            onClicked: {
                if (currentValue !== model.modelData) {
                    Constants.API.app.orders_mdl.current_page = btnGroup.model[index].number
                    refreshBtn()
                }
            }
        }
    }

    PaginationButton
    {
        Layout.preferredWidth: (root.width / 100) * 5
        Layout.preferredHeight: width
        radius: 20
        opacity: enabled ? 1 : .5
        Qaterial.ColorIcon
        {
            anchors.centerIn: parent
            iconSize: 14
            color: Dex.CurrentTheme.foregroundColor
            source: Qaterial.Icons.skipNextOutline
        }
        enabled: pageSize > 1 && currentValue < pageSize
        onClicked: {
            ++Constants.API.app.orders_mdl.current_page
            refreshBtn()
        }

    }
}
