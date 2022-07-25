import QtQuick 2.12

Column
{
    spacing: 4

    property int availableHeight: height - (childrenRect.height + (children.length - 1) * spacing)
}
