import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../Constants"
import "../Components"

Qaterial.ToolTip
{	
	id: _control
	property string text_value: ""
	contentItem: DefaultText {
	   text: qsTr(_control.text_value)
	   padding: 5
	}
	visible: parent.mouse_area.containsMouse && !sidebar.expanded
	background: FloatingBackground {auto_set_size: false}
	position: Qaterial.Style.Position.Right
} 