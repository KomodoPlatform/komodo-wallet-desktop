import QtQuick 2.12
import QtQuick.Layouts 1.12

import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex
import "../Constants"

DefaultMouseArea
{
    id: control

    property alias titleText: title.text
    property alias minimumDate: calendar.minimumDate
    property alias maximumDate: calendar.maximumDate
    property alias selectedDate: calendar.selectedDate

    signal accepted()

    width: 100
    height: column.height

    onClicked: modal.open()

    Column
    {
        id: column
        width: parent.width

        DexLabel
        {
            id: title
            text: qsTr("Date")
            font: DexTypo.overLine
            color: Dex.CurrentTheme.foregroundColor2
        }

        RowLayout
        {
            width: parent.width

            DexLabel
            {
                id: label
                text: selectedDate.toLocaleDateString(Locale.ShortFormat, "yyyy-MM-dd")
                font: DexTypo.caption
            }
            Item { Layout.fillWidth: true }
            DefaultImage
            {
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                source: Qaterial.Icons.calendarBlank

                DefaultColorOverlay
                {
                    source: parent
                    anchors.fill: parent
                    color: Dex.CurrentTheme.foregroundColor2
                }
            }
        }
    }

    DefaultModal
    {
        id: modal
        width: 300
        height: 450
        verticalPadding: 0
        horizontalPadding: 0

        DefaultCalendar
        {
            id: calendar
            anchors.fill: parent
            onSelectedDateChanged: {modal.close(); control.accepted()}
        }
    }
}
