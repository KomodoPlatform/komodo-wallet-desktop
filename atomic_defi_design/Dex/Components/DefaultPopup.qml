// Qt Imports
import QtQuick 2.12
import QtQuick.Controls 2.15 //> Popup

Popup
{
    id: popup

    y: parent.height
    x: (parent.width / 2) - (width / 2)

    closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnEscape

    background: FloatingBackground { }
}
