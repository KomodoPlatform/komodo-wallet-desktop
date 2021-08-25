import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import App 1.0

import "../Components/"

Item {
	
	id: root
	property color backgroundColor: '#15182A' 
	
	Rectangle 
	{
		id: rect
		anchors.fill: parent
		color: Qt.rgba(.0, .0, .0,.11)
	}

	function rgba255to1(n) {
		return (parseInt(n)*1) / 255
	}

	Component.onCompleted: {
		console.log(DexTheme.contentColorTop)
	}


	Flickable {

		anchors.fill: parent
		contentHeight: col.height
		Column {
			id: col
			padding: 10
			spacing: 20 
			DexAppButton {
				width: 200
				text: "Prepare"
			}

			DexAppOutlineButton {
				width: 200
				text: "Prepare"
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

			DexRectangle {
				width: 500
				height: 250
			}

			DexLabel {
				text: "Background Darker"
			}
			Row {
				spacing: 10
				Repeater {
					model: [
						{color: DexTheme.backgroundDarkColor0, name: "bg0"},
						{color: DexTheme.backgroundDarkColor1, name: "bg1"},
						{color: DexTheme.backgroundDarkColor2, name: "bg2"},
						{color: DexTheme.backgroundDarkColor3, name: "bg3"},
						{color: DexTheme.backgroundDarkColor4, name: "bg4"},
						{color: DexTheme.backgroundDarkColor5, name: "bg5"},
						{color: DexTheme.backgroundDarkColor6, name: "bg6"},
						{color: DexTheme.backgroundDarkColor7, name: "bg7"},
						{color: DexTheme.backgroundDarkColor8, name: "bg8"},
						{color: DexTheme.backgroundDarkColor9, name: "bg9"}
					]
					DexRectangle {
						width: 80 
						height: 60
						color: modelData['color']
						DexLabel {
							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: modelData['name']
							color: "cyan"
						}
					}
				}
			}
			DexLabel {
				text: "Background Lighter"
			}
			Row {
				spacing: 10
				Repeater {
					model: [
						{color: DexTheme.backgroundLightColor0, name: "bg"},
						{color: DexTheme.backgroundLightColor1, name: "bg1"},
						{color: DexTheme.backgroundLightColor2, name: "bg2"},
						{color: DexTheme.backgroundLightColor3, name: "bg3"},
						{color: DexTheme.backgroundLightColor4, name: "bg4"},
						{color: DexTheme.backgroundLightColor5, name: "bg5"}
					]
					DexRectangle {
						width: 80 
						height: 60
						color: modelData['color']
						DexLabel {
							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: modelData['name']
							color: "cyan"
						}
					}
				}
			}
			
			

			DexLabel {
				text: "Accent Darker"
			}
			Row {
				spacing: 10
				Repeater {
					model: [
						{color: DexTheme.accentDarkColor0, name: "bg0"},
						{color: DexTheme.accentDarkColor1, name: "bg1"},
						{color: DexTheme.accentDarkColor2, name: "bg2"},
						{color: DexTheme.accentDarkColor3, name: "bg3"},
						{color: DexTheme.accentDarkColor4, name: "bg4"},
						{color: DexTheme.accentDarkColor5, name: "bg5"},
						{color: DexTheme.accentDarkColor6, name: "bg6"},
						{color: DexTheme.accentDarkColor7, name: "bg7"},
						{color: DexTheme.accentDarkColor8, name: "bg8"},
						{color: DexTheme.accentDarkColor9, name: "bg9"}
					]
					DexRectangle {
						width: 80 
						height: 60
						color: modelData['color']
						DexLabel {
							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: modelData['name']
							color: "cyan"
						}
					}
				}
			}
			
			DexLabel {
				text: "Accent Lighter"
			}
			Row {
				spacing: 10
				Repeater {
					model: [
						{color: DexTheme.accentLightColor0, name: "bg"},
						{color: DexTheme.accentLightColor1, name: "bg1"},
						{color: DexTheme.accentLightColor2, name: "bg2"},
						{color: DexTheme.accentLightColor3, name: "bg3"},
						{color: DexTheme.accentLightColor4, name: "bg4"},
						{color: DexTheme.accentLightColor5, name: "bg5"}
					]
					DexRectangle {
						width: 80 
						height: 60
						color: modelData['color']
						DexLabel {
							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: modelData['name']
							color: "cyan"
						}
					}
				}
			}

			DexLabel {
				text: "Primary Darker"
			}
			Row {
				spacing: 10
				Repeater {
					model: [
						{color: DexTheme.primaryColorDarkColor0, name: "P 0"},
						{color: DexTheme.primaryColorDarkColor1, name: "P 1"},
						{color: DexTheme.primaryColorDarkColor2, name: "P 2"},
						{color: DexTheme.primaryColorDarkColor3, name: "P 3"},
						{color: DexTheme.primaryColorDarkColor4, name: "P 4"},
						{color: DexTheme.primaryColorDarkColor5, name: "P 5"},
						{color: DexTheme.primaryColorDarkColor6, name: "P 6"},
						{color: DexTheme.primaryColorDarkColor7, name: "P 7"},
						{color: DexTheme.primaryColorDarkColor8, name: "P 8"},
						{color: DexTheme.primaryColorDarkColor9, name: "P 9"}
					]
					DexRectangle {
						width: 80 
						height: 60
						color: modelData['color']
						DexLabel {
							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: modelData['name']
							color: "cyan"
						}
					}
				}
			}
			
			DexLabel {
				text: "Primary Lighter"
			}
			Row {
				spacing: 10
				Repeater {
					model: [
						{color: DexTheme.primaryColorLightColor0, name: "P "},
						{color: DexTheme.primaryColorLightColor1, name: "P 1"},
						{color: DexTheme.primaryColorLightColor2, name: "P 2"},
						{color: DexTheme.primaryColorLightColor3, name: "P 3"},
						{color: DexTheme.primaryColorLightColor4, name: "P 4"},
						{color: DexTheme.primaryColorLightColor5, name: "P 5"}
					]
					DexRectangle {
						width: 80 
						height: 60
						color: modelData['color']
						DexLabel {
							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: modelData['name']
							color: "cyan"
						}
					}
				}
			}

			DexLabel {
				text: "Foreground Darker"
			}

			Row {
				spacing: 10
				Repeater {
					model: [
						{color: DexTheme.foregroundColorDarkColor0, name: "F 0"},
						{color: DexTheme.foregroundColorDarkColor1, name: "F 1"},
						{color: DexTheme.foregroundColorDarkColor2, name: "F 2"},
						{color: DexTheme.foregroundColorDarkColor3, name: "F 3"},
						{color: DexTheme.foregroundColorDarkColor4, name: "F 4"},
						{color: DexTheme.foregroundColorDarkColor5, name: "F 5"},
						{color: DexTheme.foregroundColorDarkColor6, name: "F 6"},
						{color: DexTheme.foregroundColorDarkColor7, name: "F 7"},
						{color: DexTheme.foregroundColorDarkColor8, name: "F 8"},
						{color: DexTheme.foregroundColorDarkColor9, name: "F 9"}
					]
					DexRectangle {
						width: 80 
						height: 60
						color: modelData['color']
						DexLabel {
							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: modelData['name']
							color: "cyan"
						}
					}
				}
			}
			
			DexLabel {
				text: "Foreground Lighter"
			}
			Row {
				spacing: 10
				Repeater {
					model: [
						{color: DexTheme.foregroundColorLightColor0, name: "F "},
						{color: DexTheme.foregroundColorLightColor1, name: "F 1"},
						{color: DexTheme.foregroundColorLightColor2, name: "F 2"},
						{color: DexTheme.foregroundColorLightColor3, name: "F 3"},
						{color: DexTheme.foregroundColorLightColor4, name: "F 4"},
						{color: DexTheme.foregroundColorLightColor5, name: "F 5"}
					]
					DexRectangle {
						width: 80 
						height: 60
						color: modelData['color']
						DexLabel {
							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: modelData['name']
							color: "cyan"
						}
					}
				}
			}
			
		}
	}
	
}