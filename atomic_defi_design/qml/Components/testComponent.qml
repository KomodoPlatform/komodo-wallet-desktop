import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Layouts  1.5

Item {
	anchors.fill: parent
	Column {
		anchors.centerIn: parent
		DexAmountField {
			rightText: "CFA"
			leftText: "Amount"

		}
	}
}