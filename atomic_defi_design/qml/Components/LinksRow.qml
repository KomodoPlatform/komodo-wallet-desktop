// Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15

// Project Imports
import "../Constants" //> API

RowLayout {
    spacing: 10

    LinkIcon {
        id: discord_icon
        link: API.app_discord_url
        source: General.image_path + "icon-discord.png"
        text: qsTr("Join the Komodo Discord server")
    }

    LinkIcon {
        link: API.app_twitter_url
        source: General.image_path + "icon-twitter.png"
        text: qsTr("Follow @atomicdex on Twitter")
    }

    LinkIcon {
        link: API.app_support_url
        source: General.image_path + "icon-support.png"
        text: qsTr("Go to Komodo Support Guides")
    }
}
