import QtQuick 2.12
import QtQuick.Controls 2.2

import "../Constants"
import Dex.Themes 1.0 as Dex

Rectangle
{
    property int   searchIconLeftMargin: 13

    property alias searchIcon: _searchIcon
    property alias textField: _textField

    function forceActiveFocus() { _textField.forceActiveFocus(); }

    color: Dex.CurrentTheme.accentColor
    radius: 18

    DefaultImage
    {
        id: _searchIcon
        anchors.left: parent.left
        anchors.leftMargin: searchIconLeftMargin
        anchors.verticalCenter: parent.verticalCenter

        width: 12
        height: 12

        source: General.image_path + "exchange-search.svg"

        DefaultColorOverlay
        {
            anchors.fill: parent
            source: parent
            color: Dex.CurrentTheme.textPlaceholderColor
        }
    }

    TextField
    {
        id: _textField

        anchors.left: _searchIcon.right
        anchors.verticalCenter: _searchIcon.verticalCenter
        anchors.verticalCenterOffset: 1
        width: parent.width - x - 5
        height: parent.height

        background: null

        placeholderText: qsTr("Search")
        placeholderTextColor: Dex.CurrentTheme.textPlaceholderColor
        font.pixelSize: 14
    }
}
