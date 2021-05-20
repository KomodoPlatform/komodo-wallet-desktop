import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.12

import "Screens"
import "Constants"
import "Components"

DexWindow {
    id: window
    title: API.app_name
    visible: true
    property int previousX: 0
    property int previousY: 0
    property int real_visibility
    property bool isOsx: Qt.platform.os == "osx"
    minimumWidth: General.minimumWidth
    minimumHeight: General.minimumHeight
    
    Universal.theme: Style.dark_theme ? Universal.Dark : Universal.Light
    Universal.accent: Style.colorQtThemeAccent
    Universal.foreground: Style.colorQtThemeForeground
    Universal.background: Style.colorQtThemeBackground

    onVisibilityChanged: {
        // 3 is minimized, ignore that
        if(visibility !== 3)
            real_visibility = visibility

        API.app.change_state(visibility)

    }

    background: Item{}
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: app.globalTheme.dexBoxBackgroundColor
        border.width: 0
    }
    App {
        id: app
        anchors.fill: parent
        anchors.margins: 2
    }

    DexWindowControl { }
}
