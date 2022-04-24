import QtQuick 2.15
import QtQuick.Layouts 1.12
import "../Constants"
import App 1.0

Item
{
    property int sort_type
    property alias header_font: title.font
    property alias text: title.text_value
    property alias h_align: title.horizontalAlignment

    // Click area
    
    DexMouseArea
    {
        id: click_area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor

        onClicked:
        {
            if(current_sort === sort_type)
            {
                ascending = !ascending
            }
            else
            {
                current_sort = sort_type
                ascending = false
            }
            applyCurrentSort()
        }

        RowLayout
        {
            width:  parent.width
            height: parent.height

            Item {
                visible: title.horizontalAlignment != Text.AlignLeft
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            DexLabel
            {
                id: title
                verticalAlignment: Text.AlignVCenter
                //color: Qt.lighter(DexTheme.accentColor, click_area.containsMouse ? Style.hoverLightMultiplier : 1.0)

                // Arrow icon
                DefaultImage
                {
                    id: arrow_icon
                    anchors.left: parent.right
                    anchors.leftMargin: 3
                    anchors.verticalCenter: parent.verticalCenter
                    source: General.image_path + "arrow-" + (ascending ? "down" : "up") + ".svg"
                    width: title.font.pixelSize * 0.5
                    visible: current_sort === sort_type

                    DefaultColorOverlay
                    {
                        visible: current_sort === sort_type
                        anchors.fill: parent
                        source: arrow_icon
                        color: title.color
                    }
                }
            }


            Item {
                visible: title.horizontalAlignment != Text.AlignRight
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
