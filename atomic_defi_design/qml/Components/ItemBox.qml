import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtWebEngine 1.8
import "../Exchange/Trade/"
import "../Constants/" as Constants

InnerBackground {
    id: _control
    property bool hideHeader: false
    property bool expandedVert: false
    property bool expandedHort: false
    property bool showed: true
    property bool duplicable: false
    property bool closable: true
    property bool expandable: true
    property string title: "Default Title"
    property int minimumHeight: 40
    property int minimumWidth: 250
    property int maximumHeight: undefined
    property int maximumWidth:  splitView.maximumWidth
    property int default_minimumWidth: 40
    property int defaultHeight: 40
    property int defaultWidth: 250
    property bool contentVisible: expandable
    property bool isVertical: _control.parent.parent.orientation === Qt.Vertical
    shadowOff: true
    color: Constants.Style.colorTheme9
    property alias titleLabel: _texto

    onExpandedVertChanged: {
        if(expandedVert) {
            for(var i=0; i<_control.parent.children.length;i++){
                if (_control.parent.children[i]!==_control){
                    _control.parent.children[i].expandedVert = false
                }
            }
        }
    }
    onExpandedHortChanged: {
        if(expandedHort) {
            for(var i=0; i<_control.parent.children.length;i++){
                if (_control.parent.children[i]!==_control){
                    _control.parent.children[i].expandedHort = false
                }
            }
        }
    }
    onExpandableChanged: {
        if(!expandable){
            if(_control.parent.parent.orientation === Qt.Vertical){
                expandedVert = false

            }else {
                expandedHort = false
            }
        }
    }

    SplitView.minimumHeight: default_minimumWidth
    SplitView.minimumWidth: default_minimumWidth
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

    SplitView.preferredHeight: expandable? defaultHeight : minimumHeight
    SplitView.preferredWidth: expandable? defaultWidth : default_minimumWidth
    SplitView.fillHeight: expandedVert? true: false
    SplitView.fillWidth: expandedHort? true: false
    //SplitView.maximumWidth: maximumWidth
    property Component contentItem

    radius: 8
    ClipRRect {
        anchors.fill: parent
        radius: parent.radius
        Rectangle {
            width: parent.width
            height: 40
            radius: parent.parent.height<41? parent.parent.radius : 0
            color: Constants.Style.colorTheme9
            visible: (isVertical? true : expandable) && !_control.hideHeader
            RowLayout {
                anchors.fill: parent
                Layout.rightMargin: 10
                Layout.leftMargin: 10
                DefaultText {
                    id: _texto
                    leftPadding: 10
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    text: _control.title
                    color: Constants.Style.colorWhite4
                    bottomPadding: 5
                }
                Row {
                    Layout.alignment: Qt.AlignVCenter
                    opacity: .8
                    spacing: -8
                    Qaterial.AppBarButton {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        icon.source: _control.expandable? Qaterial.Icons.eyeOutline : Qaterial.Icons.eyeOffOutline
                        onClicked: _control.expandable =!_control.expandable
                    }
                    Qaterial.AppBarButton {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        visible: _control.expandable && _control.parent.parent.orientation === Qt.Vertical
                        icon.source: _control.expandedVert? Qaterial.Icons.unfoldLessHorizontal : Qaterial.Icons.unfoldMoreHorizontal
                        onClicked: _control.expandedVert =!_control.expandedVert
                    }
                    Qaterial.AppBarButton {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        visible: _control.expandable && _control.parent.parent.orientation === Qt.Horizontal
                        icon.source: _control.expandedHort? Qaterial.Icons.unfoldLessVertical : Qaterial.Icons.unfoldMoreVertical
                        onClicked: _control.expandedHort =!_control.expandedHort
                    }
                    Qaterial.AppBarButton {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        visible: _control.duplicable
                        icon.source: Qaterial.Icons.plus
                    }
                    Qaterial.AppBarButton {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        visible: _control.closable
                        icon.source: Qaterial.Icons.close
                    }
                }
            }
        }
        Rectangle {
            width: 40
            height: parent.height
            anchors.right: parent.right
            radius: parent.parent.height<41? parent.parent.radius : 0
            color: Constants.Style.colorTheme9
            visible: !isVertical && !expandable
            ColumnLayout {
                anchors.fill: parent
                Layout.rightMargin: 10
                Layout.leftMargin: 10
                //rotation: 90
                Column {
                    //Layout.alignment: Qt.AlignVCenter
                    opacity: .8
                    spacing: -8

                    Qaterial.AppBarButton {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        icon.source: _control.expandable? Qaterial.Icons.eyeOutline : Qaterial.Icons.eyeOffOutline
                        onClicked: _control.expandable =!_control.expandable
                    }
                    Qaterial.AppBarButton {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        visible: _control.expandable && _control.parent.parent.orientation === Qt.Vertical
                        icon.source: _control.expandedVert? Qaterial.Icons.unfoldLessHorizontal : Qaterial.Icons.unfoldMoreHorizontal
                        onClicked: _control.expandedVert =!_control.expandedVert
                    }
                    Qaterial.AppBarButton {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        visible: _control.expandable && _control.parent.parent.orientation === Qt.Horizontal
                        icon.source: _control.expandedHort? Qaterial.Icons.unfoldLessVertical : Qaterial.Icons.unfoldMoreVertical
                        onClicked: _control.expandedHort =!_control.expandedHort
                    }
                    Qaterial.AppBarButton {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        visible: _control.duplicable
                        icon.source: Qaterial.Icons.plus
                    }
                    Qaterial.AppBarButton {
                        implicitHeight: 40
                        implicitWidth: 40
                        icon.height: 17
                        icon.width: 17
                        visible: _control.closable
                        icon.source: Qaterial.Icons.close
                    }
                }
                Item {
                    Layout.fillHeight: true
                }
            }
        }
        Item {
            anchors.fill: parent
            visible: contentVisible
            Loader {
                id: _loader
                anchors.fill: parent
                anchors.topMargin: 40

                sourceComponent: _control.contentItem
            }
            LoaderBusyIndicator {
                target: _loader
            }
        }


    }
}
