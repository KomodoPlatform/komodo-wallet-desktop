import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Layouts  1.5

Item {
	id: control
	width:  200
    height: 35
    property alias value: input_field.text
	property alias field: input_field
	property alias background: _background
	readonly property int max_length: 1000
	property color textColor: theme.foregroundColor
	function reset() {
		input_field.text = ""
	}
	Rectangle {
		id: _background
	    anchors.fill: parent
	    radius: 4
	    color: theme.surfaceColor
	    border.color: theme.accentColor
	    border.width: input_field.focus? 1 : 0
	}

	RowLayout {
		anchors.fill: parent
		anchors.leftMargin: 5
		anchors.rightMargin: 5
		spacing: 2
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Rectangle {
				anchors.fill: parent
				anchors.topMargin: 1
				anchors.bottomMargin: 1
				radius: _background.radius
				color: theme.surfaceColor
				DexFlickable {
					anchors.fill: parent
					contentHeight: input_field.height
					contentWidth: width
					interactive: false
					
					TextArea.flickable: TextArea {
				        id: input_field
						horizontalAlignment: Qt.AlignLeft
						color: control.textColor
				        background: Item{}
				        wrapMode: TextEdit.Wrap
				        selectByMouse: true
				        persistentSelection: true
				        font.weight: Font.Medium
				        font.family: theme.textType.body2
						onTextChanged: {
					        if(text.length > control.max_length) {
					            console.log("too long! ", text.length)
					            text = text.substring(0, control.max_length)
					        }
				        }
				    }
				}
			}
		}
	}
}