import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0

import "../Constants" as Constants
import App 1.0
import "../Components"

import Qaterial 1.0 as Qaterial

Item {
    id: sidebar
    property bool expanded: dashboard.current_page === dashboard.idx_dashboard_exchange ? false : true
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
      
    SidebarPanel {
        id: left_rect
        visible: true
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        height: 400
    }

    ClipRRect {
        width: 185
        height: DexTheme.sidebarHightLightHeight
        radius: 1
        anchors.right: parent.right
        anchors.verticalCenter: cursor_round_edge.verticalCenter

        ClipRRect {
            height: DexTheme.sidebarHightLightHeight
            width: parent.width + 100
            radius: 10
            AnimatedRectangle {
                id: cursor
                width: 185
                height: Constants.Style.sidebarLineHeight + top_rect.radius*2
                opacity: .7
                gradient: Gradient {
                    orientation: Qt.Horizontal

                    GradientStop {
                        position: 0.1255
                        color: DexTheme.navigationSideBarButtonGradient1
                    }
                    GradientStop {
                        position: 0.4283
                        color: DexTheme.navigationSideBarButtonGradient2
                    }
                    GradientStop {
                        position: 0.7143
                        color: DexTheme.navigationSideBarButtonGradient3
                    }
                    GradientStop {
                        position: 1
                        color: DexTheme.navigationSideBarButtonGradient4 
                    }
                }
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

    // Cursor left edge
    Item {
        id: cursor_round_edge
        width: radius*2
        opacity: 0
        anchors.rightMargin: -width/2
        height: Constants.Style.sidebarLineHeight
        visible: false
        y: {
            switch(dashboard.current_page) {
                case idx_dashboard_portfolio:
                case idx_dashboard_wallet:
                case idx_dashboard_exchange:
                case idx_dashboard_addressbook:
                case idx_dashboard_news:
                case idx_dashboard_dapps:
                    return sidebar_center.y + dashboard.current_page * Constants.Style.sidebarLineHeight
                case idx_dashboard_settings:
                case idx_dashboard_support:
                    return sidebar_bottom.y + (dashboard.current_page - idx_dashboard_settings) * Constants.Style.sidebarLineHeight
            }
        }

        Behavior on y { SmoothedAnimation { duration: Constants.Style.animationDuration; velocity: -1 } }
    }

    // Content
    Item {
        anchors.right: parent.right
        width: parent.width + parent.x
        height: parent.height

        DefaultImage {
            id: app_logo
            source: expanded? "file:///"+ atomic_logo_path +  "/"+ DexTheme.bigSidebarLogo : "file:///"+atomic_logo_path +  "/"+ DexTheme.smallSidebarLogo
            anchors.horizontalCenter: parent.horizontalCenter
            y: expanded? parent.width * 0.25 : parent.width * 0.40
            transformOrigin: Item.Center
            height: expanded? 85 : 65
            scale: expanded? 1 : .8
        }

       /* Separator {
            anchors.bottom: version_text.top
            anchors.bottomMargin: 6
            width: parent.width-10
            anchors.horizontalCenter: parent.horizontalCenter
        }*/

        DexLabel {
            id: version_text
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: expanded? parent.width * 0.85 : parent.width * 1.4
            width: parent.width-5
            horizontalAlignment: DefaultText.AlignHCenter
            wrapMode: DefaultText.Wrap
            text_value: Constants.General.version_string
            font: DexTypo.caption
            color: Constants.Style.colorThemeDarkLight
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

    DexRectangle {
        anchors.right: parent.right
        height: parent.height
        width: 1
        color: DexTheme.sideBarRightBorderColor
        opacity: 1
        border.width: 0
    }

}
