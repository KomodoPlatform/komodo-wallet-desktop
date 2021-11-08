import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

Item
{
    id: _control

    property alias image: image
    property alias image_path: image.source
    property alias image_scale: image.scale
    property alias content: inner_space.sourceComponent
    property alias bottom_content: bottom_content.sourceComponent
    property double image_margin: 5
    property color backgroundColor: Dex.CurrentTheme.floatingBackgroundColor

    ColumnLayout
    {
        id: window_layout

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        transformOrigin: Item.Center
        spacing: image_margin

        DefaultImage
        {
            id: image
            Layout.maximumWidth: 300
            Layout.maximumHeight: Layout.maximumWidth * paintedHeight/paintedWidth

            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            antialiasing: true
        }

        Pane
        {
            id: pane

            leftPadding: 30
            rightPadding: leftPadding
            topPadding: leftPadding * 0.5
            bottomPadding: topPadding
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            background: DefaultRectangle
            {
                radius: 20
                color: _control.backgroundColor
            }

            contentChildren: Loader
            {
                id: inner_space
            }
        }

        Loader
        {
            id: bottom_content
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
