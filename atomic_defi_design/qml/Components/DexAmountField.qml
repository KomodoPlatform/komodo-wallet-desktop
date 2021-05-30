import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Layouts  1.5

Item {
	width:  200
    height: 35
    property alias value: input_field.text
	property alias field: input_field
	property string leftText: "Price"
	property string rightText: ""
	property alias background: _background
	property int leftWidth: -1
    anchors.centerIn: parent
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
		Item {
			visible: leftText!==""
			Layout.preferredWidth: leftWidth!==-1? leftWidth : _title_label.implicitWidth+10
			Layout.fillHeight: true
			DexLabel {
				id: _title_label
				anchors.verticalCenter: parent.verticalCenter
				leftPadding: 5
				horizontalAlignment: DexLabel.AlignHCenter
				text: leftText
				color: theme.foregroundColor
				opacity: .4
				font.pixelSize: 14
				font.weight: Font.Medium
			}
		}
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Rectangle {
				anchors.fill: parent
				anchors.topMargin: 1
				anchors.bottomMargin: 1
				radius: 0
				color: theme.surfaceColor
				DexTextField {
			        id: input_field
			        validator: RegExpValidator {
					    regExp: /(0|([1-9][0-9]*))(\.[0-9]{1,8})?/
					}
					horizontalAlignment: Qt.AlignRight
			        echoMode: hidable && hiding ? TextInput.Password : TextInput.Normal
			        background: Item{}
			        font.weight: Font.Medium
			        font.family: 'Lato'
			        anchors.fill: parent
			    }
			}
		}
		Item {
			visible: rightText!==""
			Layout.preferredWidth: _suffix_label.implicitWidth+10
			Layout.fillHeight: true
			DexLabel {
				id: _suffix_label
				anchors.centerIn: parent
				horizontalAlignment: DexLabel.AlignHCenter
				text: rightText
				color: theme.foregroundColor
				opacity: .4
				font.pixelSize: 14
				font.weight: Font.Medium
			}
		}
	}
}