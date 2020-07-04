import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0

import "../Constants"
import "../Components"

Item {
    id: sidebar
    x: -top_rect.radius
    width: 200 - x
    height: parent.height

    // Cursor
    Item {
        id: cursor
        width: 170 - cursor_round_edge.radius
        anchors.right: parent.right
        height: Style.sidebarLineHeight + top_rect.radius*2
        transformOrigin: Item.Left
        anchors.verticalCenter: cursor_round_edge.verticalCenter

        LinearGradient {
            anchors.fill: parent

            start: Qt.point(0, 0)
            end: Qt.point(parent.width, 0)

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Style.colorSidebarHighlightGradient1
                }
                GradientStop {
                    position: cursor_round_edge.radius / cursor.width
                    color: Style.colorSidebarHighlightGradient1
                }
                GradientStop {
                    position: 0.375
                    color: Style.colorSidebarHighlightGradient2
                }
                GradientStop {
                    position: 0.7292
                    color: Style.colorSidebarHighlightGradient3
                }
                GradientStop {
                    position: 1.0
                    color: Style.colorSidebarHighlightGradient4
                }
            }
        }
    }

    // Top Rect
    DefaultRectangle {
        id: top_rect
        anchors.left: parent.left
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: cursor_round_edge.top

        radius: Style.rectangleCornerRadius

        DefaultGradient { }
    }

    // Bottom Rect
    DefaultRectangle {
        id: bottom_rect
        anchors.left: parent.left
        width: parent.width
        anchors.top: cursor_round_edge.bottom
        anchors.bottom: parent.bottom

        radius: Style.rectangleCornerRadius

        DefaultGradient { }
    }


    // Left Rect
    DefaultRectangle {
        id: left_rect
        anchors.left: top_rect.left
        anchors.top: top_rect.bottom
        anchors.bottom: bottom_rect.top
        anchors.right: cursor.left
        anchors.topMargin: -top_rect.border.width
        anchors.bottomMargin: anchors.topMargin

        border.width: 0
        radius: 0

        DefaultGradient {
            end_pos: top_rect.width*0.95 / parent.width
        }
    }


    // Cursor left edge
    Rectangle {
        id: cursor_round_edge
        color: Style.colorSidebarHighlightGradient1
        width: radius*2
        anchors.rightMargin: -width/2
        height: Style.sidebarLineHeight
        anchors.right: cursor.left
        radius: Style.rectangleCornerRadius

        y: {
            switch(dashboard.current_page) {
                case General.idx_dashboard_portfolio:
                case General.idx_dashboard_wallet:
                case General.idx_dashboard_exchange:
                case General.idx_dashboard_news:
                case General.idx_dashboard_dapps:
                    return sidebar_center.y + dashboard.current_page * Style.sidebarLineHeight
                case General.idx_dashboard_settings:
                    return sidebar_bottom.y
            }
        }
    }

    // Content
    Item {
        anchors.right: parent.right
        width: parent.width + parent.x
        height: parent.height

        Image {
            source: General.image_path + Style.sidebar_atomicdex_logo
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.width * 0.25
            transformOrigin: Item.Center
            height: 85
            fillMode: Image.PreserveAspectFit
        }

        Separator {
            anchors.bottom: version_text.top
            anchors.bottomMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
        }

        DefaultText {
            id: version_text
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.width * 0.85
            text_value: API.get().empty_string + ("V. AtomicDEX PRO " + API.get().get_version())
            font.pixelSize: Style.textSizeVerySmall8
            color: Style.colorThemeDarkLight
        }

        SidebarCenter {
            id: sidebar_center
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
        }

        SidebarBottom {
            id: sidebar_bottom
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.width * 0.25
        }
    }
}








/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:150}
}
##^##*/
