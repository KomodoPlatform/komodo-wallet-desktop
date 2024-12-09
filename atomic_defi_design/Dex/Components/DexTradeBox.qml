import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import "../Exchange/Trade/"
import App 1.0
import Dex.Themes 1.0 as Dex

Rectangle {
    id: _control
    signal reload()

    property bool hideHeader: false
    property bool visibility: isVertical ? height >= 40 ? true : false : width >= 40 ? true : false
    property bool hidden: false
    property bool closed: false
    property bool expandedVert: false
    property bool expandedHort: false
    property bool showed: true
    property bool canBeFull: false
    property bool duplicable: false
    property bool closable: false
    property bool expandable: true
    property bool fullScreen: false
    property string title: "Default Title"
    property int minimumHeight: isVertical ? 40 : 250
    property int minimumWidth: isVertical ? 40 : 250
    property int maximumHeight: 9999999
    property int maximumWidth: 9999999
    property int defaultHeight: 250
    property int defaultWidth: 250
    property bool reloadable: false
    property bool contentVisible: !hidden
    property bool isVertical: _control.parent.parent.orientation === Qt.Vertical
    radius: 3
    
    function setHeight(height) {
        SplitView.preferredHeight = height
    }

    function setWidth(width) {
        SplitView.preferredWidth = width
    }

    onHiddenChanged: {
        if (isVertical && hidden) {
            SplitView.preferredHeight = 40
            SplitView.minimumHeight = 40
            SplitView.maximumHeight = 40
        } else if (isVertical && !hidden) {
            SplitView.preferredHeight = defaultHeight
            SplitView.minimumHeight = minimumHeight
            SplitView.maximumHeight = maximumHeight
            SplitView.fillHeight = true
            SplitView.view.update()
        } else if (!isVertical && hidden) {
            SplitView.preferredWidth = 40
            SplitView.minimumWidth = 40
            SplitView.maximumWidth = 40
        } else if (!isVertical && !hidden) {
            SplitView.preferredWidth = defaultWidth
            SplitView.minimumWidth = minimumWidth
            SplitView.maximumWidth = maximumWidth
            SplitView.fillWidth = true

        }
    }

    color: Dex.CurrentTheme.floatingBackgroundColor
    //border.color: DexTheme.proviewItemBoxBorderColor
    //border.width: DexTheme.proviewItemBoxBorderWidth
    
    property alias titleLabel: _texto

    function setFalseHeight() {
        SplitView.fillHeight = false
    }

    onExpandedVertChanged: {
        let splitManager = SplitView.view
        if (expandedVert) {
            if (splitManager !== null) {
                for (var i = 0; i < splitManager.itemLists.length; i++) {
                    let item = splitManager.itemLists[i]
                    if (item !== _control) {
                        try {
                            item.expandedVert = false
                            item.setFalseHeight()
                        } catch (e) {}
                    }
                }
                SplitView.fillHeight = true
            }
        } else {
            var setted = false
            if (splitManager !== null) {
                for (var i = 0; i < splitManager.itemLists.length; i++) {
                    let item = splitManager.itemLists[i]
                    if (item !== _control && setted === false) {
                        try {
                            item.expandedVert = true
                            setted = true
                        } catch (e) {}
                    }
                }
                setFalseHeight()
            }
        }
    }

    function setFalseWidth() {
        SplitView.fillWidth = false
    }

    /*onExpandedHortChanged: {
        let splitManager = SplitView.view
        if(expandedHort) {
            if(splitManager==null){
                for(var i=0; i<splitManager.itemLists.length;i++) {
                    let item =splitManager.itemLists[i]
                    if (item!==_control){
                        item.expandedHort = false
                        item.setFalseWidth()
                    }
                }
                SplitView.fillWidth = true
            }
        }
    }*/



    Behavior on SplitView.preferredHeight {
        SmoothedAnimation {
            duration: 200

        }
    }

    Behavior on SplitView.preferredWidth {
        SmoothedAnimation {
            duration: 200

        }
    }

    Component.onCompleted: {
        SplitView.minimumHeight = minimumHeight
        SplitView.minimumWidth = minimumWidth
        SplitView.maximumHeight = maximumHeight
        SplitView.maximumWidth = maximumWidth
        SplitView.preferredHeight = defaultHeight
        SplitView.preferredWidth = defaultWidth
        SplitView.fillHeight = expandedVert ? true : false
        SplitView.fillWidth = expandedHort ? true : false
    }

    property Component contentItem


    ClipRRect {
        anchors.fill: parent
        radius: parent.radius
        Item {
            width: parent.width
            height: 40
            visible: visibility && !_control.hideHeader
            RowLayout {
                anchors.fill: parent
                Layout.rightMargin: 10
                Layout.leftMargin: 10
                DexLabel {
                    id: _texto
                    leftPadding: 10
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    font.weight: Font.Medium
                    text: _control.title
                    visible: isVertical || !hidden
                    bottomPadding: 5
                }
                Row {
                    Layout.alignment: Qt.AlignVCenter
                    opacity: .8
                    spacing: -8
                    Qaterial.AppBarButton
                    {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        visible: _control.canBeFull
                        foregroundColor: Dex.CurrentTheme.foregroundColor
                        icon.source: _control.fullScreen ? Qaterial.Icons.fullscreenExit : Qaterial.Icons.fullscreen
                        onClicked: _control.fullScreen = !_control.fullScreen
                    }
                    Qaterial.AppBarButton
                    {
                        Timer
                        {
                            id: _tm
                            interval: 5000
                            running: false
                            onTriggered: parent.enabled = true
                        }

                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        foregroundColor: DexTheme.accentColor
                        visible: _control.reloadable
                        icon.source: Qaterial.Icons.refresh
                        onClicked:
                        {
                            _tm.restart();
                            enabled = false;
                            _control.reload();
                        }
                    }
                    Qaterial.AppBarButton
                    {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        foregroundColor: Dex.CurrentTheme.foregroundColor
                        icon.source: !_control.hidden ? Qaterial.Icons.eyeOutline : Qaterial.Icons.eyeOffOutline
                        onClicked: _control.hidden = !_control.hidden
                    }
                    Qaterial.AppBarButton
                    {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        foregroundColor: Dex.CurrentTheme.foregroundColor
                        visible: _control.expandable && _control.parent.parent.orientation === Qt.Vertical
                        icon.source: _control.expandedVert ? Qaterial.Icons.unfoldLessHorizontal : Qaterial.Icons.unfoldMoreHorizontal
                        onClicked: _control.expandedVert = !_control.expandedVert
                    }
                    Qaterial.AppBarButton
                    {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        foregroundColor: Dex.CurrentTheme.foregroundColor
                        visible: _control.duplicable
                        icon.source: Qaterial.Icons.plus
                    }
                    Qaterial.AppBarButton
                    {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        foregroundColor: Dex.CurrentTheme.foregroundColor
                        visible: _control.closable
                        icon.source: Qaterial.Icons.close
                        onClicked: {
                            _control.closed = true
                            _control.visible = false
                        }
                    }
                }
            }
        }
        Item
        {
            width: 40
            height: parent.height
            anchors.right: parent.right
            visible: !isVertical && hidden
            DexLabel
            {
                id: _texto2
                leftPadding: 10
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                text: _control.title
                bottomPadding: 5
                rotation: 90
                anchors.centerIn: parent
            }
            ColumnLayout
            {
                anchors.fill: parent
                Layout.rightMargin: 10
                Layout.leftMargin: 10
                Column
                {
                    opacity: .8
                    spacing: -8

                    Qaterial.AppBarButton
                    {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        foregroundColor: Dex.CurrentTheme.foregroundColor
                        icon.source: _control.expandable ? Qaterial.Icons.eyeOutline : Qaterial.Icons.eyeOffOutline
                        onClicked: _control.hidden = !_control.hidden
                    }
                    Qaterial.AppBarButton
                    {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        foregroundColor: Dex.CurrentTheme.foregroundColor
                        visible: _control.expandable && _control.parent.parent.orientation === Qt.Horizontal
                        icon.source: _control.expandedHort ? Qaterial.Icons.unfoldLessVertical : Qaterial.Icons.unfoldMoreVertical
                        onClicked: _control.expandedHort = !_control.expandedHort
                    }
                    Qaterial.AppBarButton
                    {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        foregroundColor: Dex.CurrentTheme.foregroundColor
                        visible: _control.duplicable
                        icon.source: Qaterial.Icons.plus
                    }
                    Qaterial.AppBarButton
                    {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        foregroundColor: Dex.CurrentTheme.foregroundColor
                        visible: _control.closable
                        icon.source: Qaterial.Icons.close

                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
        Item
        {
            anchors.fill: parent
            visible: contentVisible
            Loader
            {
                id: _loader
                anchors.fill: parent
                anchors.topMargin: 40

                sourceComponent: _control.contentItem
            }
            LoaderBusyIndicator
            {
                target: _loader
            }
        }


    }
}
