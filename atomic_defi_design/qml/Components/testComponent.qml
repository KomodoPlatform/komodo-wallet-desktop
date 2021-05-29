import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial

Item {
	anchors.fill: parent
	SplitView  {
		width: 600
		height: parent.height
		DexTradeBox {
			minimumWidth: 300
			background.color: Qaterial.Colors.yellow700
		}
	}
}