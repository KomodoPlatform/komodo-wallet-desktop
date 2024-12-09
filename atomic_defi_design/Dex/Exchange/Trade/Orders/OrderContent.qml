import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0

import Qaterial 1.0 as Qaterial

import App 1.0
import "../../../Components"
import "../../../Constants"
import Dex.Themes 1.0 as Dex

RowLayout
{
    property var details

    DefaultRectangle
    {
        Layout.preferredWidth: 226
        Layout.preferredHeight: 66
        radius: 10

        RowLayout
        {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 23

            DefaultImage
            {
                Layout.preferredWidth: 35
                Layout.preferredHeight: 35
                Layout.alignment: Qt.AlignVCenter

                source: General.coinIcon(!details ? atomic_app_primary_coin : details.base_coin)
            }

            ColumnLayout
            {
                Layout.fillWidth: true
                RowLayout
                {
                    Layout.fillWidth: true
                    spacing: 5
                    DexLabel
                    {
                        Layout.fillWidth: true
                        text: details ? details.base_coin : ""
                    }

                    DexLabel
                    {
                        Layout.fillWidth: true
                        text: details ? General.coinName(details.base_coin) : ""
                        wrapMode: Text.NoWrap
                        elide: Text.ElideRight
                        font.pixelSize: 11
                    }
                }

                DexLabel
                {
                    Layout.fillWidth: true
                    text: details ? details.base_amount : ""
                    font.pixelSize: 11
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                }
            }
        }
    }

    Qaterial.Icon
    {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter

        color: Dex.CurrentTheme.foregroundColor
        icon: Qaterial.Icons.swapHorizontal
    }

    DefaultRectangle
    {
        Layout.preferredWidth: 226
        Layout.preferredHeight: 66
        radius: 10

        RowLayout
        {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 23

            DefaultImage
            {
                Layout.preferredWidth: 35
                Layout.preferredHeight: 35
                Layout.alignment: Qt.AlignVCenter

                source: General.coinIcon(!details ? atomic_app_primary_coin : details.rel_coin)
            }

            ColumnLayout
            {
                Layout.fillWidth: true
                RowLayout
                {
                    Layout.fillWidth: true
                    spacing: 5
                    DexLabel
                    {
                        Layout.fillWidth: true
                        text: details ? details.rel_coin : ""
                    }

                    DexLabel
                    {
                        Layout.fillWidth: true
                        text: details ? General.coinName(details.rel_coin) : ""
                        wrapMode: Text.NoWrap
                        elide: Text.ElideRight
                        font.pixelSize: 11
                    }
                }

                DexLabel
                {
                    Layout.fillWidth: true
                    text: details ? details.rel_amount : ""
                    font.pixelSize: 11
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                }
            }
        }
    }
}
