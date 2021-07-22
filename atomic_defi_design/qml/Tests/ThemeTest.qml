import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import App 1.0

import "../Components/"

Item {
	
	Component.onCompleted: {
		DexTheme.buttonColorEnabled = DexTheme.accentColor
		DexTheme.buttonColorHovered = Qt.darker(DexTheme.accentColor, .8)
		DexTheme.buttonColorDisabled = Qt.lighter(DexTheme.accentColor, .7)
	}

	Column {
		padding: 10
		spacing: 10 
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
	}
}