import QtQuick 2.15
import Qaterial 1.0 as Qaterial

import Dex.Themes 1.0 as Dex


Item
{
    id: root
    Column
    {
        padding: 10
        spacing: 10
        Repeater
        {
            model: 20
            Rectangle
            {
                width: 200
                height: 10
                color: Dex.CurrentTheme.backgroundColor
            }
        }

    }

    function listProperty(item)
    {
        for (var p in item)
        {
            if (typeof item[p] != "function")
                if (p != "objectName")
                    console.log(p + ":" + item[p]);
        }

    }
    Component.onCompleted:
    {

        listProperty(root)

    }

}