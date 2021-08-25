import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"
import App 1.0

DefaultModal
{
    id: root

    property alias         currentIndex: stack_layout.currentIndex
    property int           targetPageIndex: currentIndex
    property alias         count: stack_layout.count
    default property alias pages: stack_layout.data

    readonly property int _modalWidth: width
    readonly property int _modalPadding: padding

    function nextPage()
    {
        if (currentIndex === count - 1)
            root.close()
        else
        {
            targetPageIndex = currentIndex + 1
            page_change_animation.start()
        }
    }

    function previousPage()
    {
        if (currentIndex === 0)
            root.close()
        else
        {
            targetPageIndex = currentIndex - 1
            page_change_animation.start()
        }
    }

    //! Appearance
    padding: 20
    leftPadding: 20
    rightPadding: 20
    bottomPadding: 15
    width: 700
    height: column_layout.height + verticalPadding * 2

    onOpened: stack_layout.opacity = 1

    SequentialAnimation {
        id: page_change_animation
        NumberAnimation { id: fade_out; target: root; property: "opacity"; to: 0; duration: Style.animationDuration }
        PropertyAction { target: root; property: "currentIndex"; value: targetPageIndex }
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: fade_out.duration }
    }

    Column {
        id: column_layout
        spacing: Style.rowSpacing
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter

        Row {
            id: page_indicator
            visible: root.count > 1
            anchors.horizontalCenter: parent.horizontalCenter

            layoutDirection: Qt.RightToLeft

            Repeater {
                model: root.count
                delegate: Item {
                    id: bundle
                    property color color: root.currentIndex >= (root.count-1 - index) ? DexTheme.modalStepColor : DexTheme.contentColorTopBold
                    width: (index === root.count-1 ? 0 : circle.width*3) + circle.width*0.5
                    height: circle.height * 1.5
                    InnerBackground {
                        id: rectangle
                        height: 2
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: -circle.width*0.5
                        anchors.right: circle.horizontalCenter
                        shadowOff: true
                        color: root.currentIndex >= (root.count-1 - index) ? bundle.color : DexTheme.hightlightColor
                    }

                    DexRectangle {
                        id: circle
                        width: 20
                        height: width
                        radius: width/2
                        border.color: root.currentIndex >= (root.count-1 - index) ? bundle.color : DexTheme.hightlightColor
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: bundle.color
                    }
                }
            }
        }

        // Inside modal
        StackLayout {
            id: stack_layout
            width: parent.width
            height: stack_layout.children[stack_layout.currentIndex].height
        }
    }
}
