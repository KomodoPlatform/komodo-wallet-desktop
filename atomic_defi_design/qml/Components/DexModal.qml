import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: control
    parent: Overlay.overlay
    property alias title: _headerBackground.text
    property alias headerBackground: _headerBackground
    property alias backgroundColor: _backgroundColor.color
    property alias currentIndex: _layoutPopup.currentIndex
    property alias header: _header.contentItem
    property alias footer: _footer.contentItem
    modal: true
    padding: 0
    Overlay.modeless: DexRectangle {
        color: DexTheme.dexBoxBackgroundColor
        opacity: .3
    }
    background: ClipRRect {
        radius: 8
        DexRectangle {
            id: _backgroundColor
            anchors.fill: parent
            border.width: 2
            radius: parent.radius
            color: DexTheme.dexBoxBackgroundColor
            Container {
                id: _header
                width: parent.width
                height: 60
                contentItem: DexModalHeader {
                    id: _headerBackground
                }
            }
            HorizontalLine {
                anchors.top: _footer.top
                width: _headerBackground.width
                opacity: .7
            }
            Container {
                id: _footer
                anchors.bottom: parent.bottom
                height: try {
                    contentItem.height
                } catch (e) {
                    0
                }
                width: parent.width
            }

        }
    }
    contentItem: StackLayout {
        id: _layoutPopup
        anchors.fill: parent
        anchors.topMargin: try {
            control.header.height
        } catch (e) {
            0
        }
        anchors.bottomMargin: try {
            control.footer.height
        } catch (e) {
            0
        }

    }

}