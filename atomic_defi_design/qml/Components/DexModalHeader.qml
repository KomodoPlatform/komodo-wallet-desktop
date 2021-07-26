import QtQuick 2.15

DexRectangle {
    id: _headerBackground
    property alias text: _title.text
    /*width: parent.width
    height: parent.height*/
    color: DexTheme.accentColor
    border.width: 0
    radius: 0
    DexLabel {
        id: _title
        anchors.verticalCenter: parent.verticalCenter
        text: ""
        opacity: .8
        font: DexTypo.head6
        leftPadding: 10
    }
    HorizontalLine {
        anchors.bottom: parent.bottom
        width: _headerBackground.width
        opacity: .7
    }
}