// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

// Project Imports
import "../Constants"
import App 1.0 //> API

RowLayout {
    spacing: 0

    LinkIcon {
        enabled: API.app_discord_url !== ""
        visible: enabled
        Layout.leftMargin: 0

        id: discord_icon
        link: API.app_discord_url
        source: General.image_path + "icon-discord.png"
        text: qsTr("Join our Discord server")
    }

    LinkIcon {
        enabled: API.app_twitter_url !== ""
        visible: enabled

        link: API.app_twitter_url
        source: General.image_path + "icon-twitter.png"
        text: qsTr("Follow us on Twitter")
    }

    LinkIcon {
        enabled: API.app_support_url !== ""
        visible: enabled
        Layout.rightMargin: 0

        link: API.app_support_url
        source: General.image_path + "icon-support.png"
        text: qsTr("Go to Support Guides")
    }
}
