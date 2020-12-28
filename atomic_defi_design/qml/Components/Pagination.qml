import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../Constants"

RowLayout {
    property int visible_page: 9//API.app.orders_mdl.current_page
    property int page_count: 48//API.app.orders_mdl.nb_pages

    PaginationButton {
        text: qsTr("Previous")
        enabled: visible_page > 1
        onClicked: --visible_page
    }

    Repeater {
        model: paginate(visible_page, page_count)
        delegate: PaginationButton {
            text: model.modelData
            button_type: model.modelData === visible_page ? "primary" : "default"
            onClicked: {
                if(visible_page !== model.modelData) {
                    visible_page = model.modelData
                }
            }
        }
    }

    PaginationButton {
        text: qsTr("Next")
        enabled: page_count > 1 && visible_page < page_count
        onClicked: ++visible_page
    }

    function paginate(visible_page, page_count) {
        const short_range_count = 5

        // Low page count
        if(page_count <= short_range_count + 2) return range(1, page_count)

        // First page is always 1
        let pages = [1]

        // Simple list for first page
        if(visible_page === 1) {
            pages = pages.concat(range(2, short_range_count))
            add(pages, Math.min(page_count, 10))
        }
        else {
            const next_pages_count = Math.min(short_range_count, page_count - visible_page)

            let prev_pages_count = short_range_count - next_pages_count

            // Add previous pages
            pages = pages.concat(range(visible_page - prev_pages_count, prev_pages_count))

            // Add next pages
            pages = pages.concat(range(visible_page, next_pages_count))

            // Add far pages
            add(pages, page_count*0.33333333)
            add(pages, page_count*0.66666666)
            add(pages, page_count)
        }

        return pages
    }

    function add(pages, page) {
        page = Math.floor(page)
        if(pages[pages.length-1] < page)
            pages.push(page)

        return pages
    }

    function range(start, count) {
        let pages = []
        for(let i = 0; i < count; ++i) pages.push(start + i)
        return pages
    }
}
