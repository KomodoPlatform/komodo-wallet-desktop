import QtQuick 2.12

import "../Components"
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

DefaultImage
{
    source: isExpanded ? "file:///" + atomic_logo_path + "/" + General.bigSidebarLogo :
                         "file:///" + atomic_logo_path + "/" + General.smallSidebarLogo

    scale: isExpanded ? .8 : .6

    DefaultText
    {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 35

        scale: 1.1
        text_value: General.version_string
        font: DexTypo.caption
        color: Dex.CurrentTheme.sidebarVersionTextColor
    }
}
