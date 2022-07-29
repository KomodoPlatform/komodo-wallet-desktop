import QtQuick 2.12

Column
{
    spacing: 4

    readonly property int availableHeight: height - (childrenRect.height + (children.length - 1) * spacing)

    function getHeight(ratio)
    {
        return (height - (children.length - 1) * spacing) * ratio
    }
}
