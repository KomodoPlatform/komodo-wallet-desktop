import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import App 1.0
import Dex.Themes 1.0 as Dex

ComboBox
{
    id: control

    property alias radius: bg_rect.radius
    property color comboBoxBackgroundColor: Dex.CurrentTheme.comboBoxBackgroundColor
    property color popupBackgroundColor: Dex.CurrentTheme.floatingBackgroundColor
    property color highlightedBackgroundColor: Dex.CurrentTheme.comboBoxDropdownItemHighlightedColor
    property color mainBackgroundColor: Dex.CurrentTheme.floatingBackgroundColor

    height: 80


    // Combobox Dropdown Button Background
    background: DexRectangle
    {
        id: bg_rect
        color: comboBoxBackgroundColor
        radius: 20
    }

    contentItem: DexComboBoxLine
    {
        id: line

        property int update_count: 0
        property var prev_details

        padding: 10

        function forceUpdateDetails()
        {
            console.log("Portfolio item data changed, force-updating the selected ticker details!")
            ++update_count
        }

        details:
        {
            const idx = combo.currentIndex

            if(idx === -1) return prev_details

            // Update count triggers the change for auto-update
            const new_details =
                              {
                update_count:           line.update_count,
                ticker:                 model.data(model.index(idx, 0), 257),
                name:                   model.data(model.index(idx, 0), 259),
                balance:                model.data(model.index(idx, 0), 260),
                main_currency_balance:  model.data(model.index(idx, 0), 261)
            }

            prev_details = new_details

            return new_details
        }

        Component.onCompleted: portfolio_mdl.portfolioItemDataChanged.connect(forceUpdateDetails)
        Component.onDestruction: portfolio_mdl.portfolioItemDataChanged.disconnect(forceUpdateDetails)
    }

    // Each dropdown item
    delegate: ItemDelegate
    {
        id: combo_item
        width: control.width
        highlighted: control.highlightedIndex === index

        contentItem: DexComboBoxLine { details: model }
        z: 5

        // Dropdown Item background
        background: DexRectangle {
            anchors.fill: combo_item
            color: combo_item.highlighted ? highlightedBackgroundColor : mainBackgroundColor
        }
    }

    indicator: Column
    {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 8
        spacing: -12

        Qaterial.Icon
        {
            width: 30
            height: 30
            color: Dex.CurrentTheme.comboBoxArrowsColor
            icon: Qaterial.Icons.chevronDown
        }
    }

    // Dropdown itself
    popup: Popup
    {
        id: combo_popup
        readonly property double max_height: 450

        width: control.width
        height: Math.min(contentItem.implicitHeight, max_height) + 20

        z: 4
        y: control.height - 1
        topMargin: 40
        bottomMargin: 10
        rightMargin: 5
        padding: 1

        contentItem: ColumnLayout
        {
            anchors.rightMargin: 5

            // Search input
            DexTextField
            {
                id: input_coin_filter
                placeholderText: qsTr("Search")

                font.pixelSize: 16
                Layout.fillWidth: true
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                Layout.preferredHeight: 40
                Layout.topMargin: Layout.leftMargin

                // Search Field Background
                background: DexRectangle
                {
                    color: control.comboBoxBackgroundColor
                    anchors.fill: parent
                    radius: control.radius
                }

                onTextChanged:
                {
                    ticker_list.setFilterFixedString(text)
                    renewIndex()
                }

                function reset()
                {
                    text = ""
                    renewIndex()
                }

                Keys.onDownPressed: control.incrementCurrentIndex()
                Keys.onUpPressed: control.decrementCurrentIndex()
                Keys.onPressed:
                {
                    if (event.key === Qt.Key_Return)
                    {
                        if (control.count > 0) control.currentIndex = 0;
                        popup.close();
                        event.accepted = true;
                    }
                }

                Connections
                {
                    target: popup
                    function onOpened()
                    {
                        input_coin_filter.reset();
                        input_coin_filter.forceActiveFocus();
                    }
                    function onClosed() { input_coin_filter.reset() }
                }
            }

            Item
            {
                Layout.maximumHeight: popup.max_height - 100
                Layout.fillWidth: true
                implicitHeight: popup_list_view.contentHeight + 5

                DexListView
                {
                    id: popup_list_view
                     // Scrollbar appears if this extra space is not added
                    model: control.popup.visible ? control.delegateModel : null
                    currentIndex: control.highlightedIndex
                    anchors.fill: parent

                    DexMouseArea
                    {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                    }
                }
            }
        }

        // Popup Background
        background: DexRectangle
        {
            width: parent.width
            height: parent.height
            radius: control.radius
            color: control.popupBackgroundColor
            colorAnimation: false
            border.width: 1
        }
    }
}
