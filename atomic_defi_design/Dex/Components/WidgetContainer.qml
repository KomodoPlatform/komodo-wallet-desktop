import QtQuick 2.12

Column
{
    readonly property string componentName: "widgetContainer"
    readonly property int availableHeight: height - (childrenRect.height + (children.length - 1) * spacing)

    function getHeight(ratio)
    {
        return (height - (children.length - 1) * spacing) * ratio
    }

    function resetSizes()
    {
        for (let i = 0; i < children.length; i++)
        {
            let child = children[i]
            child.height = child.minHeight
        }
    }

    spacing: 4
    objectName: componentName
}
