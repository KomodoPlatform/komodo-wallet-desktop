import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Constants"

RowLayout {
    spacing: 10

    LinkIcon {
        id: discord_icon
        link: "https://komodoplatform.com/discord"
        source: General.image_path + "icon-discord.png"
        text: qsTr("Join the Komodo Discord server")
    }

    LinkIcon {
        link: "https://twitter.com/AtomicDEX"
        source: General.image_path + "icon-twitter.png"
        text: qsTr("Follow @atomicdex on Twitter")
    }

    LinkIcon {
        link: "https://support.komodoplatform.com/support/home"
        source: General.image_path + "icon-support.png"
        text: qsTr("Go to Komodo Support Guides")
    }

//                    LinkIcon {
//                        link: "mailto:support@komodoplatform.com"
//                        source: General.image_path + "icon-email.png"
//                    }
}
