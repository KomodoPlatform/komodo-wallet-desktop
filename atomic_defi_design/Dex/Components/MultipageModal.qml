import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

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
            changePageAnim.start()
        }
    }

    function previousPage()
    {
        if (currentIndex === 0)
            root.close()
        else
        {
            targetPageIndex = currentIndex - 1
            changePageAnim.start()
        }
    }

    //! Appearance
    width: 676
    height: columnLayout.height + verticalPadding * 2

    onOpened: stack_layout.opacity = 1

    SequentialAnimation
    {
        id: changePageAnim
        NumberAnimation { id: fadeOut; target: root; property: "opacity"; to: 0; duration: Style.animationDuration }
        PropertyAction { target: root; property: "currentIndex"; value: targetPageIndex }
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: fadeOut.duration }
    }

    Column
    {
        id: columnLayout
        spacing: Style.rowSpacing
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter

        Row
        {
            visible: root.count > 1
            anchors.horizontalCenter: parent.horizontalCenter

            layoutDirection: Qt.RightToLeft

            Repeater
            {
                model: root.count
                delegate: Item
                {
                    width: 50
                    height: 35

                    // Border
                    Rectangle
                    {
                        width: 24
                        height: 24
                        radius: width / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        gradient: Gradient
                        {
                            orientation: Qt.Horizontal
                            GradientStop { color: Dex.CurrentTheme.modalPageCounterGradientStartColor; position: 0.5 }
                            GradientStop { color: Dex.CurrentTheme.modalPageCounterGradientEndColor; position: 0.9 }
                        }
                    }

                    Rectangle
                    {
                        width: 20
                        height: 20
                        radius: width / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        gradient: Gradient
                        {
                            orientation: Qt.Horizontal
                            GradientStop { color: root.currentIndex >= (root.count - 1 - index) ?
                                                      Dex.CurrentTheme.modalPageCounterGradientStartColor : Dex.CurrentTheme.backgroundColor; position: 0.5 }
                            GradientStop { color: root.currentIndex >= (root.count - 1 - index) ?
                                                      Dex.CurrentTheme.modalPageCounterGradientEndColor : Dex.CurrentTheme.backgroundColor; position: 0.9 }
                        }
                    }
                }
            }
        }

        // Inside modal
        StackLayout
        {
            id: stack_layout
            width: parent.width
            height: stack_layout.children[stack_layout.currentIndex].height
        }
    }
}
