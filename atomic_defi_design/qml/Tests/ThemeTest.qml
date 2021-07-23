import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import App 1.0

import "../Components/"

Item {
	
	id: root
	property color backgroundColor: '#15182A' 
	
	Rectangle 
	{
		anchors.fill: parent
		color: DexTheme.surfaceColor
	}

	Component.onCompleted: {
		


		DexTheme.buttonColorEnabled = DexTheme.accentColor
		DexTheme.buttonColorHovered = Qt.darker(DexTheme.accentColor, .8)
		DexTheme.buttonColorDisabled = Qt.lighter(DexTheme.accentColor, .7)

		DexTheme.dexBoxBackgroundColor = Qt.darker(DexTheme.backgroundColor)
		DexTheme.surfaceColor = Qt.lighter(DexTheme.backgroundColor, .4)

	}

	Column {
		padding: 10
		spacing: 20 
		DexAppButton {
			text: "enokas"
		}

		DexAppButton {
			text: "disabled"
			enabled: false
		}

		DexAppTextField {
			placeholderText: "Input"
		}
		DexSlider {

		}
		DexComboBox {
			model: ["1233","DDSDD","DFDSS"]
		}

		InnerBackground 
		{
		
			width: 400
			height: 200
		}

		FloatingBackground
		{
			width: 400
			height: 100
		}
	}
}