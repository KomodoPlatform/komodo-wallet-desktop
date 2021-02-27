import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import "../Constants"

RowLayout {
    property int visible_page: API.app.orders_mdl.current_page
    property int page_count: API.app.orders_mdl.nb_pages
    DefaultComboBox {
        readonly property int item_count: API.app.orders_mdl.limit_nb_elements
        readonly property var options: [5, 10, 25, 50, 100, 200]

        Layout.leftMargin: 0
        Layout.alignment: Qt.AlignCenter

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
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        radius: 20
        opacity: enabled? 1 : .5
        Qaterial.ColorIcon {
            anchors.centerIn: parent

            color: enabled? Style.colorWhite : Style.colorWhite6
            source: Qaterial.Icons.skipPreviousOutline
        }

        //text: qsTr("Previous")
        enabled: visible_page > 1
        onClicked: --API.app.orders_mdl.current_page
    }
    spacing: 10

    Repeater {
        model: paginate(visible_page, page_count)
        delegate: PaginationButton {
            text: model.modelData
            radius: 30
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter
            button_type: model.modelData === visible_page ? "primary" : "default"
            onClicked: {
                if(visible_page !== model.modelData)
                    API.app.orders_mdl.current_page = model.modelData
            }
        }
    }
    PaginationButton {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        radius: 20
        opacity: enabled? 1 : .5
        Qaterial.ColorIcon {
            anchors.centerIn: parent

            color: enabled? Style.colorWhite : Style.colorWhite6
            source: Qaterial.Icons.skipNextOutline
        }

        //text: qsTr("Next")
        enabled: page_count > 1 && visible_page < page_count
        onClicked:  ++API.app.orders_mdl.current_page
    }

    function paginate(visible_page, page_count) {
        const short_range_count = 5

        // Add next pages
        const next_pages_count = Math.min(short_range_count, page_count - visible_page + 1)
        let pages = range(visible_page, next_pages_count)

        // Add far pages
        const last_of_next_pages = pages[pages.length - 1]
        const diff = page_count - last_of_next_pages
        add(pages, last_of_next_pages + diff*0.33333333)
        add(pages, last_of_next_pages + diff*0.66666666)
        add(pages, page_count)

        // Add previous pages
        let prev_count = short_range_count + 3 - pages.length
        let prev_start = Math.max(visible_page - prev_count, 1)
        pages = range(prev_start, pages[0] - prev_start).concat(pages)

        // Add 1
        if(pages[0] !== 1) pages = [1].concat(pages)

        return pages
    }

    function add(pages, page) {
        page = Math.floor(page)
        if(pages.length === 0 || pages[pages.length - 1] < page)
            pages.push(page)

        return pages
    }

    function range(start, count) {
        let pages = []
        for(let i = 0; i < count; ++i) pages.push(start + i)
        return pages
    }
}
