import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import "../Constants"

RowLayout {
    id: root

    spacing: 6

    property var pageSize: API.app.orders_mdl.nb_pages
    property var currentValue: API.app.orders_mdl.current_page

    function refreshBtn() {
        currentValue = API.app.orders_mdl.current_page
         var model = []
        if (pageSize < 10) { 
            for (var i = 0; i < pageSize; i++){
                model.push({number: i+1, selected: currentValue === i + 1}) 
            }
        } else {
            
            [1, 2].map(v => model.push({number: v, selected: currentValue === v}));

            model.push({number: currentValue - 2 > 1 + 3 ? -1 : 1 + 2, selected: currentValue === 3});
            
            for (var k = Math.max(1 + 3, currentValue - 2); k <= Math.min(pageSize - 3, currentValue + 2); k++) {
                model.push({number: k, selected: currentValue === k});
            }
            
            model.push({number: currentValue + 2 < pageSize - 3 ? -1 : pageSize - 2, selected: currentValue === pageSize - 2});
            [pageSize - 1, pageSize].map(v => model.push({number: v, selected: currentValue === v}));
        }
        btnGroup.model = model
    }

    onPageSizeChanged: {
        currentValue = 1
        if (pageSize < 1) {
            pageSize = 1
        }
        refreshBtn()
    }
    DefaultComboBox {
        readonly property int item_count: API.app.orders_mdl.limit_nb_elements
        readonly property var options: [5, 10, 25, 50, 100, 200]

        Layout.leftMargin: 0
        Layout.alignment: Qt.AlignCenter
        Layout.preferredWidth: 70

        model: options
        currentIndex: options.indexOf(item_count)
        onCurrentValueChanged: API.app.orders_mdl.limit_nb_elements = currentValue
    }

    DefaultText {
        Layout.alignment: Qt.AlignCenter
        font.pixelSize: 11
        text_value: qsTr("items per page")
    }
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    PaginationButton {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: 20
        opacity: enabled? 1 : .5
        Qaterial.ColorIcon {
            anchors.centerIn: parent
            iconSize: 14
            color: theme.foregroundColor
            source: Qaterial.Icons.skipPreviousOutline
        }
        enabled: currentValue > 1
        onClicked: {
            --API.app.orders_mdl.current_page
            refreshBtn()
        }
    }


    Repeater {
        id: btnGroup
        model: [{number: 1, selected: true}]
        delegate: PaginationButton {
            text: modelData.number === -1 ? "..." : ("" + modelData.number)
            radius: 30
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            colorEnabled: modelData.number === currentValue ? 'transparent' : theme.buttonColorEnabled
            colorHovered: modelData.number === currentValue ? 'transparent' : theme.buttonColorHovered
            colorTextEnabled: modelData.number === currentValue ? theme.accentColor : theme.buttonColorTextEnabled
            onClicked: {
                if(currentValue !== model.modelData) {
                    API.app.orders_mdl.current_page = btnGroup.model[index].number
                    refreshBtn()
                }
            }
        }
    }
    PaginationButton {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: 20
        opacity: enabled? 1 : .5
        Qaterial.ColorIcon {
            anchors.centerIn: parent
            iconSize: 14
            color: theme.foregroundColor
            source: Qaterial.Icons.skipNextOutline
        }
        enabled: pageSize > 1 && currentValue < pageSize
        onClicked:  {
            ++API.app.orders_mdl.current_page
            refreshBtn()
        }
    
    }

}
