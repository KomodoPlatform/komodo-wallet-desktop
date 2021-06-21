import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0

import "../Constants"
import "../Components"

Item {
    id: sidebar
    property bool expanded: dashboard.current_page===dashboard.idx_dashboard_exchange? false : true
    readonly property alias app_logo: app_logo

    x: -top_rect.radius
    width: expanded? 200 - x : 80 - x
    Behavior on width {
        NumberAnimation {
            duration: 300
        }
    }

    height: parent.height+30

    // Cursor
    AnimatedRectangle {
        id: cursor
        width: 185 - cursor_round_edge.radius
        anchors.right: parent.right
        height: Style.sidebarLineHeight + top_rect.radius*2
        transformOrigin: Item.Left
        anchors.verticalCenter: cursor_round_edge.verticalCenter

        gradient: Gradient {
            orientation: Qt.Horizontal

            GradientStop {
                position: 0.0
                color: theme.navigationSideBarButtonGradient1
            }
            GradientStop {
                position: cursor_round_edge.radius / cursor.width
                color: theme.navigationSideBarButtonGradient1
            }
            GradientStop {
                position: 0.375
                color: theme.navigationSideBarButtonGradient2
            }
            GradientStop {
                position: 0.7292
                color: theme.navigationSideBarButtonGradient3
            }
            GradientStop {
                position: 1.0
                color: theme.navigationSideBarButtonGradient4 
            }
        }
    }

    // Top Rect
    SidebarPanel {
        id: top_rect
        visible: true
        anchors.left: parent.left
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: cursor_round_edge.top

    }

    // Bottom Rect
    SidebarPanel {
        id: bottom_rect
        anchors.left: parent.left
        width: parent.width
        anchors.top: cursor_round_edge.bottom
        anchors.bottom: parent.bottom

    }


    // Left Rect
    SidebarPanel {
        id: left_rect
        anchors.left: top_rect.left
        anchors.top: top_rect.bottom
        anchors.bottom: bottom_rect.top
        anchors.right: cursor.left
        anchors.topMargin: -top_rect.border.width
        anchors.bottomMargin: anchors.topMargin

        border.width: 0
        radius: 0

        end_pos: top_rect.width*0.95 / width
    }


    // Cursor left edge
    AnimatedRectangle {
        id: cursor_round_edge
        color: theme.navigationSideBarButtonGradient1
        width: radius*2

        anchors.rightMargin: -width/2
        height: Style.sidebarLineHeight
        anchors.right: cursor.left
        visible: true
        radius: theme.rectangleRadius

        y: {
            switch(dashboard.current_page) {
                case idx_dashboard_portfolio:
                case idx_dashboard_wallet:
                case idx_dashboard_exchange:
                case idx_dashboard_addressbook:
                case idx_dashboard_news:
                case idx_dashboard_dapps:
                    return sidebar_center.y + dashboard.current_page * Style.sidebarLineHeight
                case idx_dashboard_settings:
                case idx_dashboard_support:
                    return sidebar_bottom.y + (dashboard.current_page - idx_dashboard_settings) * Style.sidebarLineHeight
            }
        }

        Behavior on y { SmoothedAnimation { duration: Style.animationDuration; velocity: -1 } }
    }

    // Content
    Item {
        anchors.right: parent.right
        width: parent.width + parent.x
        height: parent.height

        DefaultImage {
            id: app_logo
            source: expanded? "file:///"+ atomic_logo_path +  "/"+ theme.bigSidebarLogo : "file:///"+atomic_logo_path +  "/"+ theme.smallSidebarLogo
            anchors.horizontalCenter: parent.horizontalCenter
            y: expanded? parent.width * 0.25 : parent.width * 0.40
            transformOrigin: Item.Center
            height: expanded? 85 : 65
            scale: expanded? 1 : .8
        }

        Separator {
            anchors.bottom: version_text.top
            anchors.bottomMargin: 6
            width: parent.width-10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        DexLabel {
            id: version_text
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: expanded? parent.width * 0.85 : parent.width * 1.4
            width: parent.width-5
            horizontalAlignment: DefaultText.AlignHCenter
            wrapMode: DefaultText.Wrap
            text_value: General.version_string
            font: theme.textType.caption
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
