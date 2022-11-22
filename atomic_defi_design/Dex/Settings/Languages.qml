import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"
import "../Screens"
import App 1.0


Grid
{
    Layout.alignment: Qt.AlignVCenter

    clip: true

    columns: 8
    spacing: 10

    Repeater
    {
        model: API.app.settings_pg.get_available_langs()

        delegate: ClipRRect
        {
            width: 30 // Current icons have too much space around them
            height: 30
            radius: 15
            //color: API.app.settings_pg.lang === model.modelData ? Style.colorTheme11 : mouse_area.containsMouse ? Style.colorTheme4 : Style.applyOpacity(Style.colorTheme4)

            DexImage
            {
                id: image
                anchors.centerIn: parent
                source: General.image_path + "lang/" + model.modelData + ".png"
                width: 40
                height: 40
                opacity: model.modelData === API.app.settings_pg.lang ? 1 : mouse_area.containsMouse ? 0.85 : 0.7

                // Click area
                DexMouseArea
                {
                    id: mouse_area
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true

                    onClicked:
                    {
                        API.app.settings_pg.lang = model.modelData;
                        console.info("Switched language to %1".arg(API.app.settings_pg.lang));
                        menu_list.update()
                        app.update()
                        app.pageLoader.item.switchPage(Dashboard.PageType.Portfolio)
                    }
                }
            }
        }
    }
}
