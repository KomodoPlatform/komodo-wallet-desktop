import QtQuick 2.12

import "../Components"
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

MouseArea
{
    hoverEnabled: true

    Connections
    {
        target: parent.parent

        function onIsExpandedChanged()
        {
            if (isExpanded)
            {
                waitForSidebarExpansionTimer.start();
            }
            else
            {
                versionLabel.opacity = 0;
                waitForSidebarExpansionTimer.stop();
                dexLogo.source = Dex.CurrentTheme.logoPath;
                dexLogo.scale = .5;
            }
        }
    }

    Timer
    {
        id: waitForSidebarExpansionTimer
        interval: 200
        onTriggered:
        {
            fadeInTextVerAnimation.start();
            dexLogo.source = Dex.CurrentTheme.bigLogoPath;
            dexLogo.scale = .8;
        }
    }

    NumberAnimation
    {
        id: fadeInTextVerAnimation
        target: versionLabel
        properties: "opacity"
        duration: 350
        to: 1
    }

    Image
    {
        id: dexLogo
        anchors.horizontalCenter: parent.horizontalCenter
        scale: isExpanded ? .8 : .5
        source: isExpanded ? Dex.CurrentTheme.bigLogoPath : Dex.CurrentTheme.logoPath

        Connections
        {
            target: Dex.CurrentTheme
            function onThemeChanged()
            {
                dexLogo.source = isExpanded ? Dex.CurrentTheme.bigLogoPath : Dex.CurrentTheme.logoPath
            }
        }

        DefaultText
        {
            id: versionLabel
            visible: isExpanded
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 35

            scale: 1.1
            text_value: General.version_string
            font: DexTypo.caption
            color: Dex.CurrentTheme.sidebarVersionTextColor
        }
    }
}
