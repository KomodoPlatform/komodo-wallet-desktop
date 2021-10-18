import QtQuick 2.15
import QtGraphicalEffects 1.12

import Dex.Themes 1.0 as Dex

DexRectangle
{
    id: rect

    property alias content: _innerSpace.sourceComponent

    color: Dex.CurrentTheme.innerBackgroundColor
    implicitWidth: _innerSpace.width
    implicitHeight: _innerSpace.height

    Loader
    {
        id: _innerSpace

        anchors.centerIn: parent

        layer.enabled: true

        layer.effect: OpacityMask
        {
            maskSource: Rectangle
            {
                width: _innerSpace.width
                height: _innerSpace.height
                radius: rect.radius
            }
        }
    }
}
