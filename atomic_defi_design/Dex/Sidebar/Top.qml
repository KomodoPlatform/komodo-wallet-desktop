import QtQuick 2.12

import "../Components"
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

MouseArea
{
    id: root

    hoverEnabled: true

    Connections
    {
        target: parent.parent

        function onExpanded(isExpanded)
        {
            if (isExpanded)
            {
                fadeInTextVerAnimation.start();
                dexLogo.scale = .8;
                dexLogo.source = Dex.CurrentTheme.bigLogoPath;
                dexLogo.sourceSize.width = 200;
            }
        }

        function onExpandStarted(isExpanding)
        {
            if (!isExpanding)
            {
                versionLabel.opacity = 0;
                dexLogo.scale = .5;
                dexLogo.source = Dex.CurrentTheme.logoPath;
                dexLogo.sourceSize.width = 80;
                versionLabel.opacity = 0;
            }
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

    DefaultImage
    {
        id: dexLogo
        anchors.horizontalCenter: parent.horizontalCenter

        Component.onCompleted:
        {
            sourceSize.width = parent.width
            source = isExpanded ? Dex.CurrentTheme.bigLogoPath : Dex.CurrentTheme.logoPath;
            scale = isExpanded ? .8 : .5
        }

        Connections
        {
            target: Dex.CurrentTheme
            function onThemeChanged()
            {
                dexLogo.source = isExpanded ? Dex.CurrentTheme.bigLogoPath : Dex.CurrentTheme.logoPath
            }
        }
    }

    DefaultText
    {
        id: versionLabel
        anchors.horizontalCenter: dexLogo.horizontalCenter
        anchors.top: dexLogo.bottom
        anchors.topMargin: 35

        text_value: General.version_string
        font: DexTypo.caption
        color: Dex.CurrentTheme.sidebarVersionTextColor
        visible: root.width > 120

        Component.onCompleted: opacity = isExpanded ? 1 : 0
    }
}
